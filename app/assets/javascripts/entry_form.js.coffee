$ ->
  $("#entry_form").submit((event) ->
    fields = ['title', 'author', 'password', 'content']
    errors = []
    for field in fields
      if $('#' + field).val().length == 0
        errors.push("'" + $('#' + field + '_label').text() + "'")
    unless errors.length == 0
      alert('Please input ' + errors.join(', ')+ '.')
      return false
    else
      return true
  )