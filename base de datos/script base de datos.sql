DROP database consolidado_notas;
create database consolidado_notas;
use consolidado_notas;

create table Alumno(
	codigo_alu CHAR(8) PRIMARY KEY NOT NULL,
	nombre_alu VARCHAR(40) NOT NULL,
    grado VARCHAR(40) NOT NULL,
    seccion VARCHAR(18) NOT NULL 
)ENGINE=InnoDB;
create table Consolidado_notas(
	codigo_cn INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    codigo_alu CHAR(8) NOT NULL,
	INDEX consolidado_notas_ibfk_1 (codigo_alu) VISIBLE,
		CONSTRAINT consolidado_notas_ibfk_1
		FOREIGN KEY (codigo_alu)
		REFERENCES alumno (codigo_alu)
		ON DELETE CASCADE
		ON UPDATE CASCADE
)ENGINE=InnoDB;
CREATE TABLE Area_da(
	codigo_area INT PRIMARY KEY NOT NULL,
    descripcion_area VARCHAR(40) NOT NULL
)ENGINE=InnoDB;
CREATE TABLE Area(
	codigo_cn INT NOT NULL,
    codigo_area INT NOT NULL,
    promedio_area DOUBLE NULL,
    PRIMARY KEY(codigo_cn,codigo_area),
	INDEX area_ibfk_2 (codigo_area) VISIBLE,
	CONSTRAINT area_ibfk_1
		FOREIGN KEY (codigo_cn)
		REFERENCES consolidado_notas (codigo_cn)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT area_ibfk_2
		FOREIGN KEY (codigo_area)
		REFERENCES area_da (codigo_area)
		ON DELETE CASCADE
		ON UPDATE CASCADE
)ENGINE=InnoDB;
 
create table Curso_dc(
	codigo_curso INT PRIMARY KEY NOT NULL,
    descripcion_curso VARCHAR(40) NOT NULL
)ENGINE=InnoDB;
create table Curso(
	codigo_cn INT NOT NULL,
    codigo_curso INT NOT NULL,
    nota_bimestre_I DOUBLE NULL,
    nota_bimestre_II DOUBLE NULL,
    nota_bimestre_III DOUBLE NULL,
    nota_bimestre_IV DOUBLE NULL,
    PRIMARY KEY(codigo_cn,codigo_curso),
    INDEX curso_ibfk_2 (codigo_curso) VISIBLE,
	CONSTRAINT curso_ibfk_1
		FOREIGN KEY (codigo_cn)
		REFERENCES consolidado_notas (codigo_cn)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT curso_ibfk_2
		FOREIGN KEY (codigo_curso)
		REFERENCES curso_dc (codigo_curso)
		ON DELETE CASCADE
		ON UPDATE CASCADE
)ENGINE=InnoDB;

load data infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Area_da.txt'
into table Area_da
fields terminated by ','
lines terminated by '\r\n';

load data infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Alumno.txt'
into table Alumno
fields terminated by ','
lines terminated by '\r\n';

load data infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Consolidado_notas.txt'
into table Consolidado_notas
fields terminated by ','
lines terminated by '\r\n';

load data infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Area.txt'
into table Area
fields terminated by ','
lines terminated by '\r\n';

load data infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Curso_dc.txt'
into table Curso_dc
fields terminated by ','
lines terminated by '\r\n';

load data infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Curso.txt'
into table Curso
fields terminated by ','
lines terminated by '\r\n';

delimiter //
create procedure renderizar_alumno ()
begin 
select  alumno.codigo_alu, alumno.nombre_alu, alumno.grado, alumno.seccion
from Alumno
order by 2;
end //
delimiter ;

delimiter //
create procedure insertar_alumno (in codigo_alu CHAR(8), in nombre_alu VARCHAR(40), in grado VARCHAR(40), in seccion VARCHAR(18))
begin
insert into alumno values (codigo_alu, nombre_alu, grado, seccion);
end //
delimiter ;

delimiter //
create procedure insertar_consolidado (in codigo_cn INT, in codigo_alu INT)
begin
insert into consolidado_notas values (codigo_cn, codigo_alu);
end //
delimiter ;

delimiter //
create procedure insertar_notas (in codigo_cn int ,in codigo_curso int ,in nota_bimestre_I double, in nota_bimestre_II double, in nota_bimestre_III double, in nota_bimestre_IV double)
begin
insert into Curso values (codigo_cn,codigo_curso,nota_bimestre_I, nota_bimestre_II, nota_bimestre_III, nota_bimestre_IV);
end //
delimiter ;

delimiter //
create procedure insertar_area (in codigo_cn int ,in codigo_area int ,in promedio_area double)
begin
insert into Area values (codigo_cn, codigo_area, promedio_area);
end //
delimiter ;

delimiter // 
create procedure sp_eliminar_alumno(in codigo char(8))
begin
delete from consolidado_notas.alumno a where a.codigo_alu=codigo;
end //
delimiter ;

delimiter // 
create procedure sp_buscar_alumno(in codigo char(8))
begin 
select  alumno.codigo_alu, alumno.nombre_alu, alumno.grado, alumno.seccion, curso_dc.descripcion_curso, curso.nota_bimestre_I,
curso.nota_bimestre_II, curso.nota_bimestre_III, curso.nota_bimestre_IV 
from Alumno
inner join consolidado_notas on Alumno.codigo_alu = consolidado_notas.codigo_alu
inner join area on consolidado_notas.codigo_cn = area.codigo_cn
inner join area_da on area.codigo_area = area_da.codigo_area
inner join curso on consolidado_notas.codigo_cn = curso.codigo_cn
inner join curso_dc on curso.codigo_curso = curso_dc.codigo_curso
where alumno.codigo_alu=codigo
group by alumno.codigo_alu, curso_dc.descripcion_curso
order by 2;
end //
delimiter ;

delimiter //
create procedure renderizar_notas ()
begin 
select  alumno.codigo_alu, alumno.nombre_alu, alumno.grado, alumno.seccion, curso_dc.descripcion_curso, curso.nota_bimestre_I,
curso.nota_bimestre_II, curso.nota_bimestre_III, curso.nota_bimestre_IV 
from Alumno
inner join consolidado_notas on Alumno.codigo_alu = consolidado_notas.codigo_alu
inner join area on consolidado_notas.codigo_cn = area.codigo_cn
inner join area_da on area.codigo_area = area_da.codigo_area
inner join curso on consolidado_notas.codigo_cn = curso.codigo_cn
inner join curso_dc on curso.codigo_curso = curso_dc.codigo_curso
group by alumno.codigo_alu, curso_dc.descripcion_curso
order by 2;
end //
delimiter ;

delimiter //
create procedure renderizar_area ()
begin 
select alumno.nombre_alu, area.promedio_area
from area
inner join consolidado_notas on consolidado_notas.codigo_cn = area.codigo_cn
inner join alumno on consolidado_notas.codigo_alu = alumno.codigo_alu
order by 1;
end //
delimiter ;

/*BUSCAR ALUMNO*/
delimiter // 
create procedure buscar_alumno(in codigo char(8))
begin 
select  alumno.codigo_alu, alumno.nombre_alu, alumno.grado, alumno.seccion
from Alumno
where alumno.codigo_alu=codigo;
end //
delimiter ;

DELIMITER //
CREATE PROCEDURE Actualizar_alumno( 
in codigoALumno char(8),
in nombreAlumno VARCHAR(40),
in gradoAlumno VARCHAR(40),
in seccionAlumno VARCHAR(18))
BEGIN
UPDATE alumno SET 
codigo_alu=codigoALumno,
nombre_alu =nombreAlumno,
grado= gradoAlumno,
seccion = seccionAlumno		
where codigo_alu = codigoALumno;
END //
DELIMITER ;

/*1. Que muestre los nombres de los estudiantes de cada salón con su respectivo promedio de forma ordenada*/
DELIMITER //
create PROCEDURE reporte1()
BEGIN
select alumno.codigo_alu,Alumno.nombre_alu, Alumno.seccion, Area.promedio_area
from Alumno
inner join Consolidado_notas
on Alumno.codigo_alu = Consolidado_notas.codigo_alu
inner join Area
on Consolidado_notas.codigo_cn = Area.codigo_cn
order by 1;
END //
DELIMITER ;

/*2. Que muestre las areas que lleva cada alumno */
select Alumno.nombre_alu, Area_da.descripcion_area
from Alumno
inner join Consolidado_notas
on Alumno.codigo_alu = Consolidado_notas.codigo_alu
inner join Area 
on Consolidado_notas.codigo_cn = Area.codigo_cn
inner join Area_da
on Area.codigo_area = Area_da.codigo_area
order by 1;

DELIMITER //
create PROCEDURE reporte2()
BEGIN
select Alumno.codigo_alu, Alumno.nombre_alu, Area_da.descripcion_area
from Alumno
inner join Consolidado_notas
on Alumno.codigo_alu = Consolidado_notas.codigo_alu
inner join Area 
on Consolidado_notas.codigo_cn = Area.codigo_cn
inner join Area_da
on Area.codigo_area = Area_da.codigo_area
order by 1;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE actualizar_reporte2( 
in Codigo_alu char(8),
in Alumno VARCHAR(40),
in Descripcion_area VARCHAR(40))
BEGIN
UPDATE alumno
inner join Consolidado_notas
on Alumno.codigo_alu = Consolidado_notas.codigo_alu
inner join Area 
on Consolidado_notas.codigo_cn = Area.codigo_cn
inner join Area_da
on Area.codigo_area = Area_da.codigo_area
SET 
alumno.codigo_alu=Codigo_alu,
alumno.nombre_alu=Alumno,
Area_da.descripcion_area=Descripcion_area
where alumno.codigo_alu = Codigo_alu;
END //
DELIMITER ;

delimiter // 
create procedure buscar_reporte2(in Codigo_alu varchar(40))
begin 
select  alumno.codigo_alu, Alumno.nombre_alu, Area_da.descripcion_area
from Alumno
inner join Consolidado_notas
on Alumno.codigo_alu = Consolidado_notas.codigo_alu
inner join Area 
on Consolidado_notas.codigo_cn = Area.codigo_cn
inner join Area_da
on Area.codigo_area = Area_da.codigo_area
where Alumno.codigo_alu=Codigo_alu;
end //
delimiter ;

/*3. Visualizar los estudiantes los cuales tengan 2 o más cursos desaprobados para poder así ver cuáles van a nivelación */ 
select nombre_alu, descripcion_curso  from consolidado_notas.consolidado_notas 
INNER JOIN alumno on alumno.codigo_alu=consolidado_notas.codigo_alu 
INNER JOIN curso on curso.codigo_cn=consolidado_notas.codigo_cn 
INNER JOIN curso_dc on curso_dc.codigo_curso=curso.codigo_curso 
where nota_bimestre_I<11 and (nota_bimestre_II<11 or nota_bimestre_III<11 or nota_bimestre_IV<11);

DELIMITER //
create PROCEDURE reporte3()
BEGIN
select alumno.codigo_alu,alumno.nombre_alu, descripcion_curso  from consolidado_notas
INNER JOIN alumno on alumno.codigo_alu=consolidado_notas.codigo_alu 
INNER JOIN curso on curso.codigo_cn=consolidado_notas.codigo_cn 
INNER JOIN curso_dc on curso_dc.codigo_curso=curso.codigo_curso 
where nota_bimestre_I<11 and (nota_bimestre_II<11 or nota_bimestre_III<11 or nota_bimestre_IV<11);
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE actualizar_reporte3( 
in Codigo_alu char(8),
in Alumno VARCHAR(40),
in Curso VARCHAR(40))
BEGIN
UPDATE consolidado_notas
INNER JOIN alumno on alumno.codigo_alu=consolidado_notas.codigo_alu 
INNER JOIN curso on curso.codigo_cn=consolidado_notas.codigo_cn 
INNER JOIN curso_dc on curso_dc.codigo_curso=curso.codigo_curso 
SET 
alumno.codigo_alu=Codigo_alu,
alumno.nombre_alu=Alumno,
descripcion_curso= Curso
where alumno.codigo_alu = Codigo_alu;
END //
DELIMITER ;

delimiter // 
create procedure buscar_reporte3(in Codigo_alu varchar(8))
begin 
select alumno.codigo_alu,alumno.nombre_alu, descripcion_curso  from consolidado_notas
INNER JOIN alumno on alumno.codigo_alu=consolidado_notas.codigo_alu 
INNER JOIN curso on curso.codigo_cn=consolidado_notas.codigo_cn 
INNER JOIN curso_dc on curso_dc.codigo_curso=curso.codigo_curso 
where Alumno.codigo_alu=Codigo_alu;
end //
delimiter ;

/*4. Visualizar los estudiantes que tengan más de un consolidado de notas de la I.E Trilce para saber quiénes llevan más de un año en la I.E Trilce */ 
select  alumno.codigo_alu,nombre_alu, count(consolidado_notas.codigo_alu)'cantidad de matricula' 
from consolidado_notas.consolidado_notas 
INNER JOIN alumno on alumno.codigo_alu=consolidado_notas.codigo_alu 
where consolidado_notas.codigo_alu=alumno.codigo_alu group by consolidado_notas.codigo_alu 
having count(alumno.codigo_alu)>1; 

DELIMITER //
create PROCEDURE reporte4()
BEGIN
select alumno.codigo_alu,nombre_alu, count(consolidado_notas.codigo_alu)'cantidad de matricula' 
from consolidado_notas.consolidado_notas 
INNER JOIN alumno on alumno.codigo_alu=consolidado_notas.codigo_alu 
where consolidado_notas.codigo_alu=alumno.codigo_alu group by consolidado_notas.codigo_alu 
having count(alumno.codigo_alu)>1; 
END //
DELIMITER ;

/*5. Visualizar el estudiante con mayor nota en el 1er, 2do, 3er y 4to bimestre para poder saber cuál es el estudiante de excelencia en el salón */ 
select alumno.codigo_alu, alumno.nombre_alu, max(nota_bimestre_I)'Bimestre I', max(nota_bimestre_II) 'Bimestre II', 
max(nota_bimestre_III) 'Bimestre III', max(nota_bimestre_IV) 'Bimestre IV' 
from consolidado_notas  
INNER JOIN consolidado_notas.alumno on 
consolidado_notas.alumno.codigo_alu=consolidado_notas.codigo_alu 
INNER JOIN consolidado_notas.curso on consolidado_notas.codigo_cn=consolidado_notas.codigo_cn; 

DELIMITER //
create PROCEDURE reporte5()
BEGIN
select alumno.codigo_alu, alumno.nombre_alu, max(nota_bimestre_I)'Bimestre I', max(nota_bimestre_II) 'Bimestre II', 
max(nota_bimestre_III) 'Bimestre III', max(nota_bimestre_IV) 'Bimestre IV' 
from consolidado_notas  
INNER JOIN consolidado_notas.alumno on 
consolidado_notas.alumno.codigo_alu=consolidado_notas.codigo_alu 
INNER JOIN consolidado_notas.curso on consolidado_notas.codigo_cn=consolidado_notas.codigo_cn; 
END //
DELIMITER ;

# Mostrar a los alumnos con menor promedio de area, para ver los peores puestos y tomar medidas al respecto
select nombre_alu, descripcion_area, min(promedio_area) 'Menor Promedio' from alumno 
inner join consolidado_notas on consolidado_notas.codigo_alu=alumno.codigo_alu
inner join area on consolidado_notas.codigo_cn=area.codigo_cn
inner join area_da on area.codigo_area=area.codigo_area
group by nombre_alu, descripcion_area;

delimiter //
create procedure reporte6()
begin
select nombre_alu, descripcion_area, min(promedio_area) 'Menor Promedio' from alumno 
inner join consolidado_notas on consolidado_notas.codigo_alu=alumno.codigo_alu
inner join area on consolidado_notas.codigo_cn=area.codigo_cn
inner join area_da on area.codigo_area=area.codigo_area
group by nombre_alu, descripcion_area;
end //
delimiter ;


#mostrar todas las areas
delimiter //
create procedure reporte7()
begin
select * from area_da;
end //
delimiter ;

#mostrar todos los cursos
delimiter //
create procedure reporte8()
begin
select * from curso_dc;
end //
delimiter ;




