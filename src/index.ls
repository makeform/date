module.exports =
  pkg:
    name: "@makeform/date", extend: name: '@makeform/common'
    dependencies: [
      {name: "flatpickr", path: "dist/flatpickr.min.js"}
      {name: "flatpickr", path: "dist/flatpickr.min.css", global: true}
    ]
  init: (opt) -> opt.pubsub.fire \subinit, mod: mod(opt)
mod = ({root, ctx, data, parent, t, i18n}) ->
  {ldview,flatpickr} = ctx
  lc = {}
  config:
    time: enabled: type: \boolean
  init: ->
    @on \change, ~>
      @view.get(\input).value = it or ''
      @view.render <[input content]>
    handler = ({node}) ~> @value node.value
    @view = view = new ldview do
      root: root
      action:
        input: input: handler
        change: input: handler
      init: input: ({node}) ~>
        flatpickr node, {
          # attach dialog directly after input element
          static: true
          enableTime: @mod.info.config.{}time.enabled
          dateFormat: @mod.info.config.format or (if @mod.info.config.{}time.enabled => 'Z' else 'Y-m-d')
          onOpen: (d, s, inst) ->
            # dialog may be inside a scrolling element.
            # we manually detect overflow to re-pos this dialog
            n = c = inst.calendarContainer
            c.style.bottom = "auto"
            c.style.top = "calc(100% + 2px)"
            c.classList.toggle \arrowTop, true
            c.classList.toggle \arrowBottom, false

            c.style.right = "auto"
            c.style.left = "0"
            c.classList.toggle \arrowLeft, true
            c.classList.toggle \arrowRight, false

            while n and n.getAttribute
              s = getComputedStyle(n)
              if <[overflow overflow-y overflow-x]>.filter(-> s[it] != \visible).length =>

                nb = n.getBoundingClientRect!
                cb = c.getBoundingClientRect!
                if cb.y + cb.height > nb.y + nb.height =>
                  c.style.top = "auto"
                  c.style.bottom = "calc(100% + 2px)"
                  # somehow flatpickr update classes after onOpen
                  # currently we can only setTimeout to overwrite it
                  # hopefully it's minor effect about the arrow only.
                  setTimeout (->
                    c.classList.toggle \arrowTop, false
                    c.classList.toggle \arrowBottom, true
                  ), 0

                if cb.x + cb.width > nb.x + nb.width =>
                  c.style.left = "auto"
                  c.style.right = "0"
                  # see above
                  setTimeout (->
                    c.classList.toggle \arrowLeft, false
                    c.classList.toggle \arrowRight, true
                  ), 0

                break
              n = n.parentNode

        }
      handler:
        content: ({node}) ~> if @is-empty! => 'n/a' else node.innerText = @content!
        "option-year":
          list: -> [1950 to 2050]
          key: -> it
          handler: ({node, data}) ->
            node.setAttribute \value, data
            node.innerText = t data
        "option-month":
          list: -> [1 to 12]
          key: -> it
          handler: ({node, data}) ->
            node.setAttribute \value, data
            node.innerText = t data

        "option-day":
          list: -> [1 to 31]
          key: -> it
          handler: ({node, data}) ->
            node.setAttribute \value, data
            node.innerText = t data

        input: ({node}) ~>
          readonly = !!@mod.info.meta.readonly
          if readonly => node.setAttribute \readonly, true
          else node.removeAttribute \readonly
          node.classList.toggle \is-invalid, @status! == 2
          if @mod.info.config.placeholder => node.setAttribute \placeholder, @mod.info.config.placeholder
          else node.removeAttribute \placeholder

  render: -> @view.render!

