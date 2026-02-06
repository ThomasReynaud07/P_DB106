const express = require('express')
const router = express.Router()
const db = require('../db')

function getCart(req) {
  if (!req.session.cart) req.session.cart = []
  return req.session.cart
}

router.post('/panier/add', (req, res) => {
  const articleId = Number(req.body.articleId)
  const qty = Math.max(1, Number(req.body.qty || 1))

  const cart = getCart(req)
  const existing = cart.find((i) => i.articleId === articleId)
  if (existing) existing.qty += qty
  else cart.push({ articleId, qty })

  res.redirect('/panier')
})

router.post('/panier/remove', (req, res) => {
  const articleId = Number(req.body.articleId)
  req.session.cart = getCart(req).filter((i) => i.articleId !== articleId)
  res.redirect('/panier')
})

router.post('/panier/clear', (req, res) => {
  req.session.cart = []
  res.redirect('/panier')
})

router.get('/panier', async (req, res) => {
  const cart = getCart(req)
  const ids = cart.map((i) => i.articleId)

  let articles = []
  if (ids.length) {
    const [rows] = await db.query(
      `SELECT article_id, nom, prix
       FROM t_article
       WHERE article_id IN (${ids.map(() => '?').join(',')})`,
      ids
    )
    articles = rows
  }

  const lines = cart
    .map((item) => {
      const a = articles.find((x) => x.article_id === item.articleId)
      if (!a) return null
      return { item, article: a }
    })
    .filter(Boolean)

  const total = lines.reduce((s, l) => s + Number(l.article.prix) * l.item.qty, 0)

  res.render('cart', { lines, total })
})

module.exports = router
