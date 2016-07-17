module.exports =
  dist:
    expand: true
    flatten: true
    cwd: 'app/javascripts'
    src: ['*.coffee']
    dest: '.tmp/javascripts'
    ext: '.js'
