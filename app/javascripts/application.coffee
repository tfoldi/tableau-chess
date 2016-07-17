# yo, I'm glad that you made it here

window.initViz = ->
  containerDiv = document.getElementById("vizContainer")
  vizURL = 'https://public.tableau.com/views/Chess_3/Board'
  options =
    hideTabs: true
    onFirstInteractive: ->
      viz.addEventListener(tableau.TableauEventName.MARKS_SELECTION, onMarksSelection)
      console.log "onFirstInteractive done"
  window.viz = new tableau.Viz(containerDiv, vizURL, options)

onMarksSelection = (marksEvent) ->
  marksEvent.getMarksAsync().then reportSelectedMarks

reportSelectedMarks = (marks) ->
  html = ''
  markIndex = 0
  while markIndex < marks.length
    pairs = marks[markIndex].getPairs()
    html += '<b>Mark ' + markIndex + ':</b><ul>'
    pairIndex = 0
    while pairIndex < pairs.length
      pair = pairs[pairIndex]
      html += '<li><b>Field Name:</b> ' + pair.fieldName
      html += '<br/><b>Value:</b> ' + pair.formattedValue + '</li>'
      pairIndex++
    html += '</ul>'
    markIndex++
  infoDiv = document.getElementById('markDetails')
  infoDiv.innerHTML = html

# Init chess engine, register and implement callbacks 
# 
require [ 'ToledoChess' ], (ToledoChess) ->

  aiCallback = (player, from, to) ->
    console.log player, from, to

  CreateChessboardView = ->
    x = y = i = 0
    a = '<table cellspacing=0 align=center>'
    while y < 8
      a += '<tr>'
      x = 0
      while x < 8
        i = y * 10 + x + 21
        a += '<th width=60 height=60 onclick=OnClick(' + i + ') id=o' + i + ' style=\'line-height:50px;font-size:50px;border:2px solid #dde\' bgcolor=#' + (if x + y & 1 then 'c0c0f0>' else 'f0f0f0>')
        x++
      a += '</tr>'
      y++
    a += '<tr><th colspan=8><select id=t style=\'font-size:20px\'>'
    a += '<option>&#9819;<option>&#9820;<option>&#9821;<option>&#9822;'
    a += '</select></tr></table>'
    document.write a

  DrawPieces = ->
    console.log 'DrawPieces'
    pieces = "\xa0\u265f\u265a\u265e\u265d\u265c\u265b  \u2659\u2654\u2658\u2657\u2656\u2655"
    p = undefined
    q = undefined
    p = 21
    while p < 99
      if q = document.getElementById('o' + p)
        q.innerHTML = pieces.charAt(ai.board[p] & 15)
        q.style.borderColor = if p == ai.getMoveFrom() then 'red' else '#dde'
      ++p
    return

  OnClick = (fieldID) ->
    ai.OnClick fieldID
    return

  window.OnClick = OnClick
  ai = ToledoChess
  ai.drawCallback = DrawPieces
  ai.aiCallback = aiCallback
  #CreateChessboardView()
  #DrawPieces()


     
