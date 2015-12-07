express = require('express')
osc = require('node-osc')
bodyParser = require('body-parser')
app = express()
client = new osc.Client("192.168.0.50", 9999)#'127.0.0.1', 9999)

app.use(bodyParser.urlencoded({extended:false}))
app.use(bodyParser.json())
app.use(bodyParser.json({ type: 'application/vnd.api+json' }))
app.use(express.static(__dirname + '/dist'))

app.listen(7000, ()->
  console.log("RUNNING")
)
app.engine('jade', require('jade').__express)

compLog = []
getDateTime = ->
  date = new Date
  hour = date.getHours()
  hour = (if hour < 10 then '0' else '') + hour
  min = date.getMinutes()
  min = (if min < 10 then '0' else '') + min
  sec = date.getSeconds()
  sec = (if sec < 10 then '0' else '') + sec
  month = date.getMonth() + 1
  month = (if month < 10 then '0' else '') + month
  day = date.getDate()
  day = (if day < 10 then '0' else '') + day
  return month + ':' + day + ':' + hour + ':' + min + ':' + sec

maxLog = 12
eventNumber = 0
lastSentTime = 0
log = (action, val)->
  timestamp = getDateTime()
  logObj = {
    eventNum:eventNumber,
    time:timestamp,
    action:action,
    val:val
  }
  eventNumber++
  compLog.push(logObj)
  compLog.sort((obj1, obj2)->
    return obj1.eventNum - obj2.eventNum
  )
  if(compLog.length > maxLog)
    compLog.shift()
  compLog.reverse()

log("/serverStarted", true)

app.get('/', (req,res)->
  renderObj = compLog
  res.render 'index.jade',
    compLog:renderObj
    currTime:lastSentTime
)

app.post('/time', (req, res)->
  #res.render('index.jade', {CGD:req.body.timeAmt})
  client.send('/timeChange', req.body.timeAmt)
  lastSentTime = req.body.timeAmt
  log("/timeChange", lastSentTime)
  res.redirect('/')
)
app.post('/skipTutorial', (req,res)->
  console.log("Tutorial Skipped!")
  address = '/skipTutorial'
  client.send(address)
  log(address, true)
  res.redirect('/')
)
app.post('/startGame', (req,res)->
  console.log("Start Game!")
  address = '/startGame'
  client.send(address, req.body.levelSelect)
  log(address, req.body.levelSelect)
  res.redirect('/')
)
app.post('/endGame', (req,res)->
  console.log("End Game!")
  address = '/endGame'
  client.send(address)
  log(address, true)
  res.redirect('/')
)
app.post('/enterConfig', (req,res)->
  console.log("Entered Config!")
  address = '/enterConfig'
  client.send(address)
  log(address, true)
  res.redirect('/')
)
app.post('/centerConfig', (req,res)->
  console.log("Centered!")
  address = '/centerConfig'
  client.send(address)
  log(address, true)
  res.redirect('/')
)
app.post('/exitConfig', (req,res)->
  console.log("exiting Config!")
  address = '/exitConfig'
  client.send(address)
  log(address, true)
  res.redirect('/')
)



