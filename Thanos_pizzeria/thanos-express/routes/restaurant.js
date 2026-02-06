const express = require('express')
const router = express.Router()

router.get('/restaurant', (req,res) =>{
res.render('restaurant')
})

module.exports = router