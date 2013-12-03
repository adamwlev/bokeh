
define [
  "underscore",
  "renderer/properties",
  "mapper/color/linear_color_mapper",
  "palettes/palettes",
  "./glyph",
], (_, Properties, LinearColorMapper, Palettes, Glyph) ->

  all_palettes = Palettes.all_palettes

  class ImageView extends Glyph.View

    _fields: ['image:array', 'width', 'height', 'x', 'y', 'dw', 'dh', 'palette:string']
    _properties: []

    _set_data: (@data) ->
      h = @glyph_props.v_select('dh', data)
      for i in [0..@y.length-1]
        @y[i] += h[i]

      @image_data = new Array(data.length)
      for i in [0..data.length-1]
        canvas = document.createElement('canvas');
        canvas.width = width[i];
        canvas.height = height[i];
        ctx = canvas.getContext('2d');
        image_data = ctx.getImageData(0, 0, width[i], height[i]);
        cmap = new LinearColorMapper({}, {
          palette: all_palettes[@palette[i]]
        })
        buf = cmap.v_map_screen(img[i])
        buf8 = new Uint8ClampedArray(buf);
        image_data.data.set(buf8)
        ctx.putImageData(image_data, 0, 0);
        @image_data[i] = canvas

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
        ctx.scale(1,-1)
        ctx.translate(0, -y_offset)
        ctx.drawImage(@image_data[i], @sx[i]|0, @sy[i]|0, @sw[i], @sh[i])
        ctx.translate(0, y_offset)
        ctx.scale(1,-1)
        ctx.translate(0, -y_offset)

      ctx.setImageSmoothingEnabled(old_smoothing)
      ctx.restore()

  # name Image conflicts with js Image
  class ImageGlyph extends Glyph.Model
    default_view: ImageView
    type: 'Glyph'

    display_defaults: () ->
      return _.extend(super(), {
        level: 'underlay'
      })

  return {
    "Model": ImageGlyph,
    "View": ImageView,
  }

