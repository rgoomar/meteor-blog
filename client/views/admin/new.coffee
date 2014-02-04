Template.blogAdminNew.rendered = ->
  $('.post-form').parsley()
  $('[name=title]').focus().val ''

  @editor = ace.edit 'editor'
  @editor.setTheme 'ace/theme/chrome'
  @editor.setFontSize 14
  @editor.renderer.setShowPrintMargin false
  @editor.renderer.setShowGutter false
  @editor.setHighlightActiveLine true
  @editor.getSession().setMode 'ace/mode/markdown'
  @editor.getSession().setUseWrapMode true

  @editor.on 'change', _.debounce((e) =>
    height = @editor.getSession().getDocument().getLength() * @editor.renderer.lineHeight + @editor.renderer.scrollBar.getWidth()
    $('#editor, #preview').height height
    @editor.resize()
  , 250)

  $label = $('.body-label')
  $switch = $('.make-switch')
  $editor = $('#editor')
  $preview = $('#preview')
  $document = $(document)

  $switch.bootstrapSwitch().on 'switch-change', (e, data) =>
    if data.value
      $editor.hide()
      val = marked @editor.getValue()
      $label.text 'Preview'
      return $preview.html(val).show()

    $editor.show()
    @editor.focus()
    $label.text 'Body'
    $preview.hide()

  # Needed for keyboard shortcut
  justpressed = justtoggled = false
  isMac = (window.navigator.platform.toLowerCase().indexOf('mac') >= 0)
  ctrl = if isMac then 'metaKey' else 'ctrlKey'
  if isMac
    $('.ctrl-label').html '&#8984;'

  $document.on 'keyup', (e) ->
    if justpressed and not justtoggled and e[ctrl] and e.which is 80
      e.preventDefault()
      $switch.bootstrapSwitch 'toggleState'
    justpressed = justtoggled = false

  $document.on 'keydown', (e) ->
    justpressed = true
    if e[ctrl] and e.which is 80
      e.preventDefault()
      $switch.bootstrapSwitch 'toggleState'
      justtoggled = true

flash = (status, post) ->
  setTimeout ->
    $('.status').hide().html(status).fadeIn 'slow', ->
      setTimeout ->
        Router.go "blogAdminEdit", slug: post.slug
      , 2500
  , 100

Template.blogAdminNew.events

  'click .for-publishing': (e, tpl) ->
    e.preventDefault()

    if not $('.post-form').parsley 'validate'
      return

    post = Post.create
      title: $('[name=title]').val()
      body: tpl.editor.getValue()
      published: true
      createdAt: new Date()
      updatedAt: new Date()
      publishedAt: new Date()
      userId: Meteor.userId()

    flash 'Publishing...', post

  'click .for-saving': (e, tpl) ->
    e.preventDefault()

    if not $('.post-form').parsley 'validate'
      return

    post = Post.create
      title: $('[name=title]').val()
      body: tpl.editor.getValue()
      published: false
      createdAt: new Date()
      updatedAt: new Date()
      userId: Meteor.userId()

    if post.errors
      return alert(_(post.errors[0]).values()[0])

    flash 'Saving...', post