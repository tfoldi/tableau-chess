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
        'images/{,*/}*.{webp,png,jpg,ico,gif}',
      ]
    ]
