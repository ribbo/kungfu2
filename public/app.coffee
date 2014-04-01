# Open a socket to the node server
socket = io.connect 'http://192.168.0.72:8888'

# On document ready
$ ->



    # Servo function
    servo =
        sweep: (state = stop) ->
            socket.emit 'sweep',
                'state': state
            return
        pan: (direction = right) ->
            socket.emit 'pan',
                'direction': direction
            return
        position: (position = 0) ->
            socket.emit 'position',
                'position': position
            return



    # Radar data response
    socket.on 'radar', (obj) ->
        console.log obj

    # Motion detection response
    socket.on 'motion', (bool) ->
        if bool
            $('.motion').show()
        else
            $('.motion').hide()

    # IR state response
    socket.on 'irReady', () ->
        $('.proximity').removeAttr 'disabled'



    # Start radar sweep
    $('body').on 'click', '.start', ->
        servo.sweep 'start'
        $('.start, .left, .right, .reset').attr 'disabled', 'disabled'

    # Stop radar sweep
    $('body').on 'click', '.stop', ->
        servo.sweep 'stop'
        $('.start, .left, .right, .reset').removeAttr 'disabled'

    # Pan radar left
    $('body').on 'click', '.left', ->
        servo.pan 'left'

    # Pan radar right
    $('body').on 'click', '.right', ->
        servo.pan 'right'

    # Reset radar position
    $('body').on 'click', '.reset', ->
        servo.position 0

    # Proximity checkbox
    $('.proximity').change () ->
        if $(this).is ':checked'
            socket.emit 'ir', true
            $('.start, .stop, .left, .right, .reset').attr 'disabled', 'disabled'
        else
            socket.emit 'ir', false
            $('.start, .stop, .left, .right, .reset').removeAttr 'disabled'


# series = undefined
# hours = undefined
# minVal = undefined
# maxVal = undefined
# vizBody = undefined
# w = 400
# h = 400
# vizPadding =
#   top: 10
#   right: 0
#   bottom: 15
#   left: 0

# radius = undefined
# radiusLength = undefined
# ruleColor = "#CCC"


# loadViz = ->
#   loadData()
#   buildBase()
#   setScales()
#   addAxes()
#   draw()
#   return

# loadData = ->
#   randomFromTo = randomFromTo = (from, to) ->
#     Math.floor Math.random() * (to - from + 1) + from

#   series = [
#     []
#     []
#   ]
#   hours = []
#   i = 0
#   while i < 24
#     series[0][i] = randomFromTo(0, 20)
#     series[1][i] = randomFromTo(5, 15)
#     hours[i] = i #in case we want to do different formatting
#     i += 1
#   mergedArr = series[0].concat(series[1])
#   minVal = d3.min(mergedArr)
#   maxVal = d3.max(mergedArr)

#   #give 25% of range as buffer to top
#   maxVal = maxVal + ((maxVal - minVal) * 0.25)
#   minVal = 0

#   #to complete the radial lines
#   i = 0
#   while i < series.length
#     series[i].push series[i][0]
#     i += 1
#   return

# buildBase = ->
#   viz = d3.select("#viz").append("svg:svg").attr("width", w).attr("height", h).attr("class", "vizSvg")
#   viz.append("svg:rect").attr("id", "axis-separator").attr("x", 0).attr("y", 0).attr("height", 0).attr("width", 0).attr "height", 0
#   vizBody = viz.append("svg:g").attr("id", "body")
#   return

# setScales = ->
#   heightCircleConstraint = undefined
#   widthCircleConstraint = undefined
#   circleConstraint = undefined
#   centerXPos = undefined
#   centerYPos = undefined

#   #need a circle so find constraining dimension
#   heightCircleConstraint = h - vizPadding.top - vizPadding.bottom
#   widthCircleConstraint = w - vizPadding.left - vizPadding.right
#   circleConstraint = d3.min([
#     heightCircleConstraint
#     widthCircleConstraint
#   ])
#   radius = d3.scale.linear().domain([
#     minVal
#     maxVal
#   ]).range([
#     0
#     circleConstraint / 2
#   ])
#   radiusLength = radius(maxVal)

#   #attach everything to the group that is centered around middle
#   centerXPos = widthCircleConstraint / 2 + vizPadding.left
#   centerYPos = heightCircleConstraint / 2 + vizPadding.top
#   vizBody.attr "transform", "translate(" + centerXPos + ", " + centerYPos + ")"
#   return

# addAxes = ->
#   radialTicks = radius.ticks(5)
#   vizBody.selectAll(".circle-ticks").remove()
#   vizBody.selectAll(".line-ticks").remove()

#   circleAxes = vizBody.selectAll(".circle-ticks")
#     .data(radialTicks)
#     .enter()
#     .append("svg:g")
#     .attr("class", "circle-ticks")

#   circleAxes.append("svg:circle").attr("r", (d, i) ->
#     radius d
#   ).attr("class", "circle")
#     .style("stroke", ruleColor)
#     .style "fill", "none"

#   circleAxes.append("svg:text").attr("text-anchor", "middle").attr("dy", (d) ->
#     -1 * radius(d)
#   ).text String

#   lineAxes = vizBody.selectAll(".line-ticks").data(hours).enter().append("svg:g").attr("transform", (d, i) ->
#     "rotate(" + ((i / hours.length * 360) - 90) + ")translate(" + radius(maxVal) + ")"
#   ).attr("class", "line-ticks")


#   lineAxes.append("svg:line").attr("x2", -1 * radius(maxVal)).style("stroke", ruleColor).style "fill", "none"
#   lineAxes.append("svg:text").text(String).attr("text-anchor", "middle").attr "transform", (d, i) ->
#     (if (i / hours.length * 360) < 180 then null else "rotate(180)")

#   return

# draw = ->
#   groups = undefined
#   lines = undefined
#   linesToUpdate = undefined
#   highlightedDotSize = 4
#   groups = vizBody.selectAll(".series").data(series)
#   groups.enter().append("svg:g").attr("class", "series").style("fill", (d, i) ->
#     if i is 0
#       "green"
#     else
#       "blue"
#   ).style "stroke", (d, i) ->
#     if i is 0
#       "green"
#     else
#       "blue"

#   groups.exit().remove()
#   #close the line
#   lines = groups.append("svg:path").attr("class", "line").attr("d", d3.svg.line.radial().radius((d) ->
#     0
#   ).angle((d, i) ->
#     i = 0  if i is 24
#     (i / 24) * 2 * Math.PI
#   )).style("stroke-width", 3).style("fill", "none")
#   groups.selectAll(".curr-point").data((d) ->
#     [d[0]]
#   ).enter().append("svg:circle").attr("class", "curr-point").attr "r", 0
#   groups.selectAll(".clicked-point").data((d) ->
#     [d[0]]
#   ).enter().append("svg:circle").attr("r", 0).attr "class", "clicked-point"
#   lines.attr "d", d3.svg.line.radial().radius((d) ->
#     radius d
#   ).angle((d, i) ->
#     i = 0  if i is 24
#     #close the line
#     (i / 24) * 2 * Math.PI
#   )
#   return