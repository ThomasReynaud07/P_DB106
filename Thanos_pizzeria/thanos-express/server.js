const express = require('express')
const session = require('express-session')
require('dotenv').config()

const menuRoutes = require('./routes/menu')
const cartRoutes = require('./routes/cart')
const checkoutRoutes = require('./routes/checkout')
const restaurantRoutes = require('./routes/restaurant')

const app = express()

app.set('view engine', 'ejs')
app.use(express.urlencoded({ extended: true }))

app.use(
  session({
    secret: process.env.SESSION_SECRET,
    resave: false,
    saveUninitialized: true,
  })
)

// panier dispo dans toutes les views
app.use((req, res, next) => {
  res.locals.cartCount = (req.session.cart || []).reduce((s, i) => s + i.qty, 0)
  next()
})

app.get('/', (req, res) => res.redirect('/menu'))

app.use(menuRoutes)
app.use(cartRoutes)
app.use(checkoutRoutes)
app.use(restaurantRoutes)
app.use(express.static('public'))

app.listen(process.env.PORT, () => {
  console.log(`✅ Server: http://localhost:${process.env.PORT}`)
})
