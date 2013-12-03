
define [
  "underscore",
  "renderer/properties",
  "./glyph",
], (_, Properties, Glyph) ->

  class QuadView extends Glyph.View

    _fields: ['right', 'left', 'bottom', 'top']
    _properties: ['line', 'fill']

    _map_data: () ->
      [@sx0, @sy0] = @plot_view.map_to_screen(@left,  @glyph_props.left.units,  @top,    @glyph_props.top.units)
      [@sx1, @sy1] = @plot_view.map_to_screen(@right, @glyph_props.right.units, @bottom, @glyph_props.bottom.units)

    _mask_data: () ->
      ow = @plot_view.view_state.get('outer_width')
      oh = @plot_view.view_state.get('outer_height')
      for i in [0..@mask.length-1]
        if (@sx0[i] < 0 and @sx1[i] < 0) or (@sx0[i] > ow and @sx1[i] > ow) or (@sy0[i] < 0 and @sy1[i] < 0) or (@sy0[i] > oh and @sy1[i] > oh)
          @mask[i] = false
        else
          @mask[i] = true

    _render: (ctx, glyph_props, use_selection) ->
      for i in [0..@sx0.length-1]

        if isNaN(@sx0[i] + @sy0[i] + @sx1[i] + @sy1[i]) or not @mask[i]
          continue

        if glyph_props.fill_properties.do_fill
          glyph_props.fill_properties.set_vectorize(ctx, i)
          ctx.fillRect(@sx0[i], @sy0[i], @sx1[i]-@sx0[i], @sy1[i]-@sy0[i])

        if glyph_props.line_properties.do_stroke
          ctx.beginPath()
          ctx.rect(@sx0[i], @sy0[i], @sx1[i]-@sx0[i], @sy1[i]-@sy0[i])
          glyph_props.line_properties.set_vectorize(ctx, i)
          ctx.stroke()

    draw_legend: (ctx, x1, x2, y1, y2) ->
      ## dummy legend function just draws a circle.. this way
      ## even if we have a differnet glyph shape, at least we get the
      ## right colors present
      glyph_props = @glyph_props
      line_props = glyph_props.line_properties
      fill_props = glyph_props.fill_properties
      ctx.save()

      reference_point = @get_reference_point()
      if reference_point?
        glyph_settings = reference_point
        left = @glyph_props.select('left', glyph_settings)
        top  = @glyph_props.select('top', glyph_settings)
        right  = @glyph_props.select('right', glyph_settings)
        bottom = @glyph_props.select('bottom', glyph_settings)
        [sx0, sy0] = @plot_view.map_to_screen([left], @glyph_props.left.units,
          [top], @glyph_props.top.units)
        [sx1, sy1] = @plot_view.map_to_screen([right], @glyph_props.right.units,
          [bottom], @glyph_props.bottom.units)
        data_w = sx1[0] - sx0[0]
        data_h = sy1[0] - sy0[0]
      else
        glyph_settings = glyph_props
        data_w = 1
        data_h = 1
      border = line_props.select(line_props.line_width_name, glyph_settings)
      data_w = data_w - 2*border
      data_h = data_h - 2*border
      w = Math.abs(x2-x1)
      h = Math.abs(y2-y1)
      ratio1 = w / data_w
      ratio2 = h / data_h
      ratio = _.min([ratio1, ratio2])
      w = ratio * data_w
      h = ratio * data_h
      x = (x1 + x2) / 2 - (w / 2)
      y = (y1 + y2) / 2 - (h / 2)
      ctx.beginPath()
      ctx.rect(x, y, w, h)
      if fill_props.do_fill
        fill_props.set(ctx, glyph_settings)
        ctx.fill()
      if line_props.do_stroke
        line_props.set(ctx, glyph_settings)
        ctx.stroke()

      ctx.restore()


  class Quad extends Glyph.Model
    default_view: QuadView
    type: 'Glyph'

    display_defaults: () ->
      return _.extend(super(), {
        fill_color: 'gray'
        fill_alpha: 1.0

        line_color: 'red'
        line_width: 1
        line_alpha: 1.0
        line_join: 'miter'
        line_cap: 'butt'
        line_dash: []
        line_dash_offset: 0
      })

  return {
    "Model": Quad,
    "View": QuadView,
  }
