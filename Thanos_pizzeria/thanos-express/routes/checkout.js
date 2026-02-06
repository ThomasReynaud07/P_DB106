const express = require('express')
const router = express.Router()
const db = require('../db')

function getCart(req) {
  if (!req.session.cart) req.session.cart = []
  return req.session.cart
}

router.get('/checkout', (req, res) => {
  const cart = getCart(req)
  if (!cart.length) return res.redirect('/panier')
  res.render('checkout')
})

router.post('/checkout', async (req, res) => {
  const cart = getCart(req)
  if (!cart.length) return res.redirect('/panier')

  const { nom, prenom, courriel, telephone, type, mode } = req.body
  const { rue, npa, localite } = req.body

  // récupère prix actuels
  const ids = cart.map((i) => i.articleId)
  const [articles] = await db.query(
    `SELECT article_id, prix
     FROM t_article
     WHERE article_id IN (${ids.map(() => '?').join(',')})`,
    ids
  )

  const total = cart.reduce((s, line) => {
    const a = articles.find((x) => x.article_id === line.articleId)
    return s + (a ? Number(a.prix) * line.qty : 0)
  }, 0)

  const conn = await db.getConnection()
  try {
    await conn.beginTransaction()

    // 1) client
    const [clientRes] = await conn.query(
      `INSERT INTO t_client (nom, prenom, courriel, telephone)
       VALUES (?, ?, ?, ?)`,
      [nom, prenom, courriel, telephone]
    )
    const clientId = clientRes.insertId

    // 2) adresse si livraison
    let adresseId = null
    if (type === 'livraison') {
      const [adrRes] = await conn.query(
        `INSERT INTO t_adresse (client_fk, rue, npa, localite)
         VALUES (?, ?, ?, ?)`,
        [clientId, rue, npa, localite]
      )
      adresseId = adrRes.insertId
    }

    // 3) commande
    const [cmdRes] = await conn.query(
      `INSERT INTO t_commande (client_fk, type, adresse_fk, date_creation, statut)
       VALUES (?, ?, ?, NOW(), 'validee')`,
      [clientId, type, adresseId]
    )
    const commandeId = cmdRes.insertId

    // 4) lignes
    for (const line of cart) {
      const a = articles.find((x) => x.article_id === line.articleId)
      if (!a) continue

      await conn.query(
        `INSERT INTO t_ligne_commande (commande_fk, article_fk, quantite, prix_unitaire, parent_ligne_fk)
         VALUES (?, ?, ?, ?, NULL)`,
        [commandeId, line.articleId, line.qty, a.prix]
      )
    }

    // 5) paiement
    await conn.query(
      `INSERT INTO t_paiements (commande_fk, mode, montant, date_paiement)
       VALUES (?, ?, ?, NOW())`,
      [commandeId, mode, total.toFixed(2)]
    )

    await conn.commit()
    req.session.cart = []

    res.redirect(`/confirmation/${commandeId}`)
  } catch (e) {
    await conn.rollback()
    console.error(e)
    res.status(500).send('Erreur checkout')
  } finally {
    conn.release()
  }
})

router.get('/confirmation/:id', (req, res) => {
  res.render('confirmation', { commandeId: req.params.id })
})

module.exports = router
