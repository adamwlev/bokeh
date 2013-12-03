
define [
  "underscore",
  "renderer/properties",
  "./glyph",
], (_, Properties, Glyph) ->

  glyph_properties = Properties.glyph_properties

  class ImageRGBAView extends Glyph.View

    _fields: ['image:array', 'width', 'height', 'x', 'y', 'dw', 'dh']
    _properties: []

    _set_data: (@data) ->
      h = @glyph_props.v_select('dh', data)
      for i in [0..@y.length-1]
        @y[i] += h[i]

      if not @image_data? or @image_data.length != data.length
        @image_data = new Array(data.length)

      if not @image_canvas? or @image_canvas.length != data.length
        @image_canvas = new Array(data.length)

      for i in [0..data.length-1]
        if not @image_canvas[i]? or (@image_canvas[i].width != width[i] or @image_canvas[i].height != height[i])
          @image_canvas[i] = document.createElement('canvas')
          @image_canvas[i].width = width[i];
          @image_canvas[i].height = height[i];
          ctx = @image_canvas[i].getContext('2d');
          @image_data[i] = ctx.createImageData(width[i], height[i])
        ctx = @image_canvas[i].getContext('2d');
        @image_data[i].data.set(new Uint8ClampedArray(img[i]))
        ctx.putImageData(@image_data[i], 0, 0);

    _map_data: () ->
      [@sx, @sy] = @plot_view.map_to_screen(@x, @glyph_props.x.units, @y, @glyph_props.y.units)
      @sw = @distance(@data, 'x', 'dw', 'edge')
      @sh = @distance(@data, 'y', 'dh', 'edge')

    _render: (ctx, glyph_props, use_selection) ->
      old_smoothing = ctx.getImageSmoothingEnabled()
      ctx.setImageSmoothingEnabled(false)

      for i in [0..@sx.length-1]

        if isNaN(@sx[i] + @sy[i] + @sw[i] + @sh[i])
          continue

        y_offset = @sy[i]+@sh[i]/2

        ctx.translate(0, y_offset)
        ctx.scale(1, -1)
        ctx.translate(0, -y_offset)
        ctx.drawImage(@image_canvas[i], @sx[i]|0, @sy[i]|0, @sw[i], @sh[i])
        ctx.translate(0, y_offset)
        ctx.scale(1, -1)
        ctx.translate(0, -y_offset)

      ctx.setImageSmoothingEnabled(old_smoothing)
      ctx.restore()

  # name Image conflicts with js Image
  class ImageRGBAGlyph extends Glyph.Model
    default_view: ImageRGBAView
    type: 'Glyph'

    display_defaults: () ->
      return _.extend(super(), {
        level: 'underlay'
      })

  return {
    "Model": ImageRGBAGlyph,
    "View": ImageRGBAView,
  }
