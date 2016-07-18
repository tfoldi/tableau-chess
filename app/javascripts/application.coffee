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
        getSheet().applyFilterAsync "Field Name + Piece", "", tableau.FilterUpdateType.ALL
        .then ->
          viz.addEventListener(tableau.TableauEventName.MARKS_SELECTION, onMarksSelection)
        .then ->
          drawPieces()
          setInfo "Feel free to make your first move!"
    window.viz = new tableau.Viz(containerDiv, vizURL, options)

  onMarksSelection = (marksEvent) ->
    marksEvent.getMarksAsync().then marksSelected

  getSheet = ->
    _.first window.viz.getWorkbook().getActiveSheet().getWorksheets()

  selectMark = (field, value) ->
    getSheet().selectMarksAsync(field, value, tableau.SelectionUpdateType.REPLACE)

  marksSelected = (marks) ->
    html = ''
    if marks.length == 1
      fieldID =  _.findWhere(
                     _.first(marks).getPairs(),
                     fieldName: 'ATTR(Toledo Field ID)'
                   ).formattedValue

      html = 'Selected field: ' + fieldID
      ai.OnClick fieldID
    else if marks.length > 1
      html = 'Please select only one field'

    setInfo html


  setInfo = (msg) ->
    infoDiv = document.getElementById('chessLog')
    infoDiv.innerHTML = msg
    console.log msg
    

  aiCallback = (player, from, to) ->
    console.log player, from, to

  pieces = "\xa0\u265f\u265a\u265e\u265d\u265c\u265b  \u2659\u2654\u2658\u2657\u2656\u2655"
  
  drawPieces = ->
    console.log 'drawPieces'
   
    board = _.map(
      _.range 21, 99
      (p) -> "#{p}#{pieces.charAt(ai.board[p] & 15)}"
    )
    console.log "board: #{board}"
    getSheet().applyFilterAsync(
        "Toledo ID + Piece",
        board,
        tableau.FilterUpdateType.REPLACE
    )

 
  # Load AI, set callbacks
  ai = ToledoChess
  ai.drawCallback = drawPieces
  ai.aiCallback = aiCallback

  # make initViz a top level exported function
  window.initViz = initViz

  # TODO: kill me, just for convenient debug
  window.getSheet = getSheet
  window.ai = ai

