let project = new Project('scenegraph');
project.addSources('Sources');
project.addSources('kha-sdf-painter/Sources');
project.addShaders('kha-sdf-painter/Shaders/**');
resolve(project);
