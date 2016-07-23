# yo, I'm glad that you made it here


# 
require [ 'ToledoChess' ], (ToledoChess) ->

  # Tableau related initializations. 
  # Init viz, register event listener
  #
  initViz = ->
    logInfo "Info: Chessboard is loading, please wait"

    containerDiv = document.getElementById("vizContainer")
    vizURL = 'https://public.tableau.com/views/Chess_3/Board'
    options =
      hideTabs: true
      hideToolbar: true
      onFirstInteractive: ->
        getSheet().applyFilterAsync "Field Name + Piece", "", tableau.FilterUpdateType.ALL
        .then ->
          viz.addEventListener(tableau.TableauEventName.MARKS_SELECTION, onMarksSelection)
        .then ->
          viz.addEventListener(tableau.TableauEventName.PARAMETER_VALUE_CHANGE, onParamChange)
        .then ->
          drawPieces()
          logInfo "Info: Feel free to make your first move!"
    window.viz = new tableau.Viz(containerDiv, vizURL, options)

  onMarksSelection = (marksEvent) ->
    marksEvent.getMarksAsync().then marksSelected

  onParamChange = (parameterEvent) ->
    parameterEvent.getParameterAsync().then parameterSelected

  getSheet = ->
    _.first window.viz.getWorkbook().getActiveSheet().getWorksheets()

  selectMark = (field, value) ->
    getSheet().selectMarksAsync(field, value, tableau.SelectionUpdateType.REPLACE)

  parameterSelected = (parameter) ->
    value = parameter.getCurrentValue().value
    logInfo "Info: Promote pawn to: #{pieces[value]}"
    ai.promotePawnTo = value

  marksSelected = (marks) ->
    if marks.length == 1
      fieldID =  _.findWhere(
                     _.first(marks).getPairs(),
                     fieldName: 'ATTR(Toledo Field ID)'
                   ).formattedValue
      ai.OnClick fieldID
      unless ai.getMoveFrom() == fieldID
        logInfo "Warn: You cannot select #{toFieldName fieldID}"
        getSheet().clearSelectedMarksAsync()
    else if marks.length > 1
      logInfo 'Error: Please select only one field'

  toFieldName = (fieldId) ->
    String.fromCharCode("A".charCodeAt(0) + fieldId % 10-1) +
      parseInt( 11 - fieldId / 10 )

  logInfo = (msg) ->
    console.log msg
    $('.console-log-div')
      .stop()
      .animate { scrollTop: $('.console-log-div')[0].scrollHeight }, 800
    
  aiCallback = (player, from, to) ->
    logInfo "Move: #{if player == 0 then "Computer" else "Player"} #{toFieldName from} -> #{toFieldName to}"

  pieces = "\xa0\u265f\u265a\u265e\u265d\u265c\u265b  \u2659\u2654\u2658\u2657\u2656\u2655"
  
  drawPieces = ->
    #logInfo "Debug: Reload chessboard"
    board = _.map(
      _.range 21, 99
      (p) -> "#{p}#{pieces.charAt(ai.board[p] & 15)}"
    )
    getSheet().applyFilterAsync(
        "Toledo ID + Piece",
        board,
        tableau.FilterUpdateType.REPLACE
    )

 
  # Load AI, set callbacks
  ai = ToledoChess
  ai.drawCallback = drawPieces
  ai.aiCallback = aiCallback

  # Init our viz when all things are loaded
  initViz()

  # TODO: kill me, just for convenient debug
  window.getSheet = getSheet
  window.ai = ai

