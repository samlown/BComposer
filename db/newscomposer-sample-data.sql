-- phpMyAdmin SQL Dump
-- version 2.8.1
-- http://www.phpmyadmin.net
-- 
-- Host: localhost
-- Generation Time: Jun 16, 2006 at 01:46 PM
-- Server version: 4.1.12
-- PHP Version: 5.0.5-2ubuntu1.2
-- 
-- Database: 'newscomposer'
-- 

-- 
-- Dumping data for table 'bulletins'
-- 

INSERT INTO bulletins (id, project_id, templet_id, title, notes, date_released, date_updated) VALUES (1, 1, 0, 'Buletin 00', 'Primero Boletin de FAES', '2006-06-15 11:13:00', '2006-06-15 11:13:00');

-- 
-- Dumping data for table 'entries'
-- 

INSERT INTO entries (id, section_id, title, style, body, image_link, image_text, link, link_text, date_created, date_updated) VALUES (1, 2, 'Aznar presenta a Michael Portillo: "El pueblo britÃ¡nico fue atacado por los enemigos de nuestra civilizaciÃ³n"', '', 'El presidente de la FundaciÃ³n para el AnÃ¡lisis y los Estudios Sociales (FAES), JosÃ© MarÃ­a Aznar, ha presentado al polÃ­tico inglÃ©s Michael Portillo.\r\n\r\nEntre las palabras que Aznar dedicÃ³ a Portillo han destacado aquellas referidas a su labor como miembro activo del Partido Conservador inglÃ©s, especialmente cuando aterrizÃ³ en Ã©l a finales de los aÃ±os 70.\r\n\r\nEl presidente de FAES aprovechÃ³ para hacer un homenaje al pueblo britÃ¡nico por su comportamiento ejemplar tras la tragedia que sufriÃ³ el pasado 7 de julio: ?Han vuelto a dar una lecciÃ³n de unidad y de patriotismo?.', 'http://www.fundacionfaes.com/imagenes/control/Atlantismo_190506_170.jpg', '', 'http://www.fundacionfaes.org/documentos/Campus_05-_Discursos_Aznar-pres_Portillo.doc', 'Lea la intervenciÃ³n completa de JosÃ© MarÃ­a Aznar', '2006-06-16 10:50:00', '2006-06-16 10:50:00'),
(2, 2, 'Michael Portillo ha destacado el nuevo giro que estÃ¡ dando el multiculturalismo en Gran BretaÃ±a', '', 'Michael Portillo, ministro de Defensa en el Ãºltimo Gobierno conservador inglÃ©s participÃ³ en el curso ?El pluralismo en las democracias: la cuestiÃ³n del multiculturalismo?.\r\n\r\nQuizÃ¡ el ideal que muchos desean es un paÃ­s cuya poblaciÃ³n proviene de muchos orÃ­genes culturales y Ã©tnicos, la cual ahora presume de ser britÃ¡nica y subscribe los valores britÃ¡nicos y occidentales, y sin embargo, celebra tambiÃ©n las costumbres y fiestas de sus raÃ­ces.\r\n\r\nLa derecha americana habla con sorprendente confianza sobre sÃ­ misma. Es una interesante combinaciÃ³n entre moral elevada acompaÃ±ada de materialismo. En este sentido, la libertad y el Ã©xito econÃ³mico han situado a la cultura occidental por encima de las demÃ¡s.', 'http://www.fundacionfaes.com/imagenes/control/Atlantismo_190506_170.jpg', 'Esta imagen es una prueba!', 'http://www.fundacionfaes.org/documentos/Campus_05-Discurso_Portillo.doc', 'Lea la intervenciÃ³n completa de Michael Portillo', '2006-06-16 10:52:00', '2006-06-16 10:52:00'),
(3, 2, 'AndrÃ©s Ollero, Ignacio SÃ¡nchez CÃ¡mara y Ã?lvaro RodrÃ­guez han debatido sobre los valores universales', '', 'AndrÃ©s Ollero, catedrÃ¡tico de FilosofÃ­a del Derecho; Ignacio SÃ¡nchez CÃ¡mara, catedrÃ¡tico de FilosofÃ­a del Derecho y Ã?lvaro RodrÃ­guez debatieron en torno a la pregunta: Â¿Existen los valores universales? Este fue el tÃ­tulo de la mesa redonda, que fue moderada por Santiago Mora Figueroa, diplomÃ¡tico y escritor.\r\n\r\nPara Ollero, la pregunta debe matizarse ya que para reconocer quÃ© valores son universales conviene preguntarse si estos valores existen realmente, "para que existe posibilidad de conocimiento, debe haber posibilidad de conocimiento", aseverÃ³ Ollero.\r\n\r\nPor otro lado, Ignacio SÃ¡nchez CÃ¡mara subraya que no se puede afirmar la validez universal de los valores "ya que la elecciÃ³n de los valores no es un proceso estrictamente racional o lÃ³gico".\r\n\r\nMientras, Ã?lvaro RodrÃ­guez reflexiona sobre la existencia de valores morales trascendentes. Con ese fin, lanzÃ³ la interrogante: Â¿QuÃ© ha ocurrido en el mundo occidental para que se dÃ© esta negaciÃ³n clamorosa del valor tan bÃ¡sico como la vida? Para Ã©l, la respuesta estÃ¡ en la generalizaciÃ³n del nihilismo.\r\n', '', 'AquÃ­ hay texto en lugar de una imagen', 'http://www.fundacionfaes.org/documentos/Campus_05-Resumen_mesa_16.07.05_I.doc', 'Resumen mesa de debate', '2006-06-16 10:53:00', '2006-06-16 10:53:00'),
(4, 3, 'JosÃ© MarÃ­a Aznar LÃ³pez', '', 'Presidente de FAES y Presidente de Honor del Partido Popular.', 'http://www.pp.es/uploads/images/ComiteEjecutivo/JoseMariaAznarLopez.jpg', '', 'http://www.pp.es/index.asp?p=6370&c=6ffcc0d3641930e3d8980ec43343ccc5', '', '2006-06-16 11:02:00', '2006-06-16 11:02:00');

-- 
-- Dumping data for table 'projects'
-- 

INSERT INTO projects (id, name, desciption, date_updated) VALUES (1, 'Campus FAES', 'Boletin para el Campus FAES', '2006-06-08 11:21:00');

-- 
-- Dumping data for table 'sections'
-- 

INSERT INTO sections (id, bulletin_id, name, title, style, description, type, link, link_text, date_created, date_updated) VALUES (1, 0, '', 'Aznar presenta a Michael Portillo: "El pueblo britÃ¡nico fue atacado por los enemigos de nuestra civilizaciÃ³n"', 'centro', 'El presidente de la FundaciÃ³n para el AnÃ¡lisis y los Estudios Sociales (FAES), JosÃ© MarÃ­a Aznar, ha presentado al polÃ­tico inglÃ©s Michael Portillo.\r\n\r\nEntre las palabras que Aznar dedicÃ³ a Portillo han destacado aquellas referidas a su labor como miembro activo del Partido Conservador inglÃ©s, especialmente cuando aterrizÃ³ en Ã©l a finales de los aÃ±os 70.\r\n\r\nEl presidente de FAES aprovechÃ³ para hacer un homenaje al pueblo britÃ¡nico por su comportamiento ejemplar tras la tragedia que sufriÃ³ el pasado 7 de julio: ?Han vuelto a dar una lecciÃ³n de unidad y de patriotismo?.', NULL, 'http://www.fundacionfaes.org/documentos/Campus_05-_Discursos_Aznar-pres_Portillo.doc', NULL, '2006-06-15 13:51:20', '2006-06-15 14:50:29'),
(2, 1, 'Cuerpo Centro', '', 'centro', '', NULL, '', '', '2006-06-15 13:59:06', '2006-06-15 14:58:51'),
(3, 1, 'Personas de Faes', '', 'personas', '', NULL, '', '', '2006-06-16 11:02:44', '2006-06-16 11:20:00');

-- 
-- Dumping data for table 'templet_layouts'
-- 


-- 
-- Dumping data for table 'templets'
-- 

INSERT INTO templets (id, project_id, name, description, date_created, date_updated) VALUES (5, 1, 'Marqueta Principal', 'La Marqueta principal para el boletin de campus FAES.', '2006-06-16 11:53:00', '2006-06-16 12:31:01');

-- 
-- Dumping data for table 'users'
-- 

