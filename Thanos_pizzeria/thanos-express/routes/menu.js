const express = require('express')
const router = express.Router()
const db = require('../db')

router.get('/menu', async (req, res) => {
  const [articles] = await db.query(
    `SELECT article_id, type, nom, prix, tva
     FROM t_article
     WHERE actif = 1
     ORDER BY type, nom`
  )

  res.render('menu', { articles })
})

module.exports = router
