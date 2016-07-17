# yo, I'm glad that you made it here


# 
require [ 'ToledoChess' ], (ToledoChess) ->

  # Tableau related initializations. 
  # Init viz, register event listener
  #
  initViz = ->
    containerDiv = document.getElementById("vizContainer")
    vizURL = 'https://public.tableau.com/views/Chess_3/Board'
    options =
      hideTabs: true
      onFirstInteractive: ->
        viz.addEventListener(tableau.TableauEventName.MARKS_SELECTION, onMarksSelection)
        console.log "onFirstInteractive done, we have our board"
    window.viz = new tableau.Viz(containerDiv, vizURL, options)

  onMarksSelection = (marksEvent) ->
    marksEvent.getMarksAsync().then reportSelectedMarks

  getSheet = ->
    _.first window.viz.getWorkbook().getActiveSheet().getWorksheets()

  selectMark = (field, value) ->
    getSheet().selectMarksAsync(field, value, tableau.SelectionUpdateType.REPLACE)

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
    #ai.OnClick FieldID


  # Init chess engine, register and implement callbacks 
  aiCallback = (player, from, to) ->
    console.log player, from, to

  DrawPieces = ->
    console.log 'DrawPieces'
    pieces = "\xa0\u265f\u265a\u265e\u265d\u265c\u265b  \u2659\u2654\u2658\u2657\u2656\u2655"
    q = undefined
    p = 21
    while p < 99
      if q = document.getElementById('o' + p)
        q.innerHTML = pieces.charAt(ai.board[p] & 15)
        q.style.borderColor = if p == ai.getMoveFrom() then 'red' else '#dde'
      ++p

  OnClick = (fieldID) ->
    ai.OnClick fieldID


  window.initViz = initViz
  ai = ToledoChess
  ai.drawCallback = DrawPieces
  ai.aiCallback = aiCallback
  # TODO: kill me
  window.getSheet = getSheet
  window.ai = ai 

     
