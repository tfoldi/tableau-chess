module.exports =
  tmp:
    src: 'app/index.html'
    dest: '.tmp/index.html'
  html:
    files: [
      expand: true,
      dot: true,
      cwd: 'app'
      dest: 'dist'
      src: ['{,*/}*.html']
    ]
  # Skip grunt-requirejs and avoid warnings
  requirejs:
    files: [
      {
        src: 'bower_components/requirejs/require.js'
        dest: 'dist/javascripts/require.js'
      }
      {
        src: 'bower_components/requirejs/require.js'
        dest: '.tmp/javascripts/require.js'
      }]
  bower:
    expand: true
    src: ['bower_components/**']
    dest: '.tmp'
  dist:
    files: [
      expand: true,
      dot: true,
      cwd: 'app',
      dest: 'dist',
      src: [
        '*.{ico,png,txt}',
        '.htaccess',
        'javascripts/*.js',
        'images/{,*/}*.{webp,png,jpg,ico,gif}',
      ]
    ]
