$(document).on "turbolinks:load", ->

  $(".open_more").click (e) ->
    e.preventDefault()
    $(this).next('.details').toggle()
    return

  $(".onclick_open_backdrop").click (e) ->
    e.preventDefault()
    $(this).children('.snowflake_popover').popover('show')
    $('.popover_backdrop').show()
    return

  $(document).on "click", ".close, .popover_backdrop", (e) ->
    e.preventDefault()
    $('.snowflake_popover').popover('hide')
    $('.popover_backdrop').hide()
    return

  $('[data-toggle="popover"]').popover
    html: true
    trigger: 'manual'
    content: ->
      $(this).children('.popover_content').html()

  debounceIntervalMs = ->
    return 240

  shiftUrl = (url, regex, shifts) ->
    change = (str, p1, p2, offset, text) ->
      return p1 + (parseInt(p2) + parseInt(shifts))

    text = String(url)
    return text.replace regex, change
    
  $("a.debounce_this").click (e) ->
    e.preventDefault()

    if !window.forwardShiftAmount?
      window.forwardShiftAmount = 0
    if window.debounceTimeout?
      clearTimeout(window.debounceTimeout)
      window.forwardShiftAmount = window.forwardShiftAmount + if (e.currentTarget.dataset.directionForward == 'true') then 1 else -1
      console.log(window.forwardShiftAmount)

    regex = new RegExp("(" + e.currentTarget.dataset.debounceParam + "=)(-?\\d+)", "g")
    delayedPageChange = ->
      location.href = newHref

    newHref = shiftUrl(e.currentTarget.href, regex, window.forwardShiftAmount)
    window.debounceTimeout = setTimeout(delayedPageChange, debounceIntervalMs())
    return

  return
