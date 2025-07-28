module.exports = function(grunt) {
  grunt.initConfig({
    jshint: {
      files: ['routes/**/*.js', 'models/**/*.js', 'core/**/*.js', 'server.js'],
      options: {
        esversion: 6
      }
    },
    uglify: {
      build: {
        src: 'server.js',
        dest: 'build/server.min.js'
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-uglify');

  grunt.registerTask('default', ['jshint', 'uglify']);
};
