
from flask import Flask, render_template, request, flash, redirect, url_for
import pymysql

app = Flask(__name__)

# conexion mysql


def conexion():
    return pymysql.connect(host='localhost',
                           password='harold134679',
                           user='root',
                           db='consolidado_notas',
                           port=3306)


print(conexion())

# sesion
app.secret_key = 'mysecretkey'


@app.route('/')
def Index():
    lista_alumno = renderizar_alumno()
    return render_template('home_alumno.html', datos=lista_alumno)


@app.route('/añadir_datos')
def añadir_datos():
    lista_alumno = renderizar_notas()
    return render_template('añadir_datos.html', datos=lista_alumno)


@app.route('/add_alumno', methods=['POST'])
def Alumno():
    if request.method == 'POST':
        codigo_alu = request.form['codigo_alu']
        nombre_alu = request.form['nombre_alu']
        grado = request.form['grado']
        seccion = request.form['seccion']
        insertar_alumno(codigo_alu, nombre_alu, grado, seccion)
        flash('Alumno añadido satisfactoriamente')
        return redirect(url_for('añadir_datos'))


@app.route('/add_consolidado', methods=['POST'])
def Consolidado():
    if request.method == 'POST':
        codigo_cn = request.form['codigo_cn']
        codigo_alu = request.form['codigo_alu']
        insertar_consolidado(codigo_cn, codigo_alu)
        flash('Consolidado añadido satisfactoriamente')
        return redirect(url_for('añadir_datos'))


@app.route('/add_notas', methods=['POST'])
def Notas():
    if request.method == 'POST':
        codigo_cn = request.form['codigo_cn']
        codigo_curso = request.form['codigo_curso']
        nota_bimestre_I = request.form['nota_bimestre_I']
        nota_bimestre_II = request.form['nota_bimestre_II']
        nota_bimestre_III = request.form['nota_bimestre_III']
        nota_bimestre_IV = request.form['nota_bimestre_IV']
        insertar_notas(codigo_cn, codigo_curso, nota_bimestre_I,
                       nota_bimestre_II, nota_bimestre_III, nota_bimestre_IV)
        flash('Notas añadidas satisfactoriamente')
        return redirect(url_for('añadir_datos'))


@app.route('/add_promedio', methods=['POST'])
def Promedio():
    if request.method == 'POST':
        codigo_cn = request.form['codigo_cn']
        codigo_area = request.form['codigo_area']
        promedio_area = request.form['promedio_area']
        insertar_area(codigo_cn, codigo_area, promedio_area)
        flash('Alumno añadido satisfactoriamente')
        return redirect(url_for('añadir_datos'))


@app.route('/buscar', methods=['POST'])
def Buscar():
    if request.method == 'POST':
        codigo_alu = request.form['codigo_alu']
        lista_alumno = busqueda(codigo_alu)
        return render_template('busqueda.html', datos=lista_alumno)


def busqueda(codigo_alu):
    con = conexion()
    alumno_lista = []
    with con.cursor() as c:
        c.execute("call sp_buscar_alumno(%s)", (codigo_alu))
        alumno_lista = c.fetchall()
    con.close()
    return alumno_lista


def insertar_alumno(codigo_alu, nombre_alu, grado, seccion):
    con = conexion()
    with con.cursor() as c:
        c.execute("call insertar_alumno(%s,%s,%s,%s)",
                  (codigo_alu, nombre_alu, grado, seccion))
    con.commit()
    con.close()


def insertar_notas(codigo_cn, codigo_curso, nota_bimestre_I, nota_bimestre_II, nota_bimestre_III, nota_bimestre_IV):
    con = conexion()
    with con.cursor() as c:
        c.execute("call insertar_notas(%s,%s,%s,%s,%s,%s)",
                  (codigo_cn, codigo_curso, nota_bimestre_I, nota_bimestre_II, nota_bimestre_III, nota_bimestre_IV))
    con.commit()
    con.close()


def insertar_consolidado(codigo_cn, codigo_alu):
    con = conexion()
    with con.cursor() as c:
        c.execute("call insertar_consolidado(%s,%s)",
                  (codigo_cn, codigo_alu))
    con.commit()
    con.close()


def insertar_area(codigo_cn, codigo_area, promedio_area):
    con = conexion()
    with con.cursor() as c:
        c.execute("call insertar_area(%s,%s,%s)",
                  (codigo_cn, codigo_area, promedio_area))
    con.commit()
    con.close()


def renderizar_alumno():
    con = conexion()
    alumno_lista = []
    with con.cursor() as c:
        c.execute('call renderizar_alumno();')
        alumno_lista = c.fetchall()
    con.close()
    return alumno_lista


def renderizar_notas():
    con = conexion()
    alumno_lista = []
    with con.cursor() as c:
        c.execute('call renderizar_notas();')
        alumno_lista = c.fetchall()
    con.close()
    return alumno_lista


@app.route('/eliminar/<string:codigo_alu>')
def Eliminar(codigo_alu):
    eliminar_alumno(codigo_alu)
    flash('Alumno eliminado satisfactoriamente')
    return redirect(url_for('Index'))


def eliminar_alumno(codigo_alu):
    con = conexion()
    with con.cursor() as c:
        c.execute("call sp_eliminar_alumno(%s)", (codigo_alu))
    con.commit()
    con.close()


@app.route('/editar/<string:codigo_alu>')
def get_editar(codigo_alu):
    lista_alumno = buscar_alumno(codigo_alu)
    return render_template('editar_consolidado.html', dato=lista_alumno[0])


@app.route('/update/<codigo_alu>', methods=['POST'])
def update_alumno(codigo_alu):
    if request.method == 'POST':
        codigo_alu = request.form['codigo_alu']
        nombre_alu = request.form['nombre_alu']
        grado = request.form['grado']
        seccion = request.form['seccion']
        actualizar_alumno(codigo_alu, nombre_alu, grado, seccion)
        return redirect(url_for('Index'))


def actualizar_alumno(codigo_alu, nombre_alu, grado, seccion):
    con = conexion()
    with con.cursor() as c:
        c.execute("call Actualizar_alumno(%s,%s,%s,%s)",
                  (codigo_alu, nombre_alu, grado, seccion))
    con.commit()
    con.close()


def buscar_alumno(codigo_alu):
    con = conexion()
    alumno_lista = []
    with con.cursor() as c:
        c.execute("call buscar_alumno(%s)", (codigo_alu))
        alumno_lista = c.fetchall()
    con.close()
    return alumno_lista


@app.route('/reportes')
def reportes():
    return render_template('reportes.html')


# 1 Que muestre los nombres de los estudiantes de cada salón con su respectivo promedio y area de forma ordenada
@app.route('/reporte1')
def reporte1():
    lista_alumno = reporte1_1()
    return render_template('reporte1.html', datos=lista_alumno)


def reporte1_1():
    con = conexion()
    alumno_lista = []
    with con.cursor() as c:
        c.execute('call reporte1();')
        alumno_lista = c.fetchall()
    con.close()
    return alumno_lista


# 2 Que muestre las áreas que lleva cada alumno
@app.route('/reporte2')
def reporte2():
    lista_alumno = reporte2_1()
    return render_template('reporte2.html', datos=lista_alumno)


def reporte2_1():
    con = conexion()
    alumno_lista = []
    with con.cursor() as c:
        c.execute('call reporte2();')
        alumno_lista = c.fetchall()
    con.close()
    return alumno_lista


@app.route('/editar_reporte2/<string:Codigo_alu>')
def editar_reporte2(Codigo_alu):
    lista_alumno = buscar_reporte2(Codigo_alu)
    return render_template('editar_reporte2.html', dato=lista_alumno[0])


@app.route('/update_reporte2/<Codigo_alu>', methods=['POST'])
def update_reporte2(Codigo_alu):
    if request.method == 'POST':
        Codigo_alu = request.form['Codigo_alu']
        Alumno = request.form['Alumno']
        Descripcion_area = request.form['Descripcion_area']
        actualizar_reporte2(Codigo_alu, Alumno, Descripcion_area)
        return redirect(url_for('reporte2'))


def actualizar_reporte2(Codigo_alu, Alumno, Descripcion_area):
    con = conexion()
    with con.cursor() as c:
        c.execute("call actualizar_reporte2(%s,%s,%s)",
                  (Codigo_alu, Alumno, Descripcion_area))
    con.commit()
    con.close()


def buscar_reporte2(Codigo_alu):
    con = conexion()
    alumno_lista = []
    with con.cursor() as c:
        c.execute("call buscar_reporte2(%s)", (Codigo_alu))
        alumno_lista = c.fetchall()
    con.close()
    return alumno_lista

# 3 Visualizar los estudiantes los cuales tengan 2 o más cursos desaprobados para poder así ver cuáles van a nivelación


@app.route('/reporte3')
def reporte3():
    lista_alumno = reporte3_1()
    return render_template('reporte3.html', datos=lista_alumno)


def reporte3_1():
    con = conexion()
    alumno_lista = []
    with con.cursor() as c:
        c.execute('call reporte3();')
        alumno_lista = c.fetchall()
    con.close()
    return alumno_lista


@app.route('/editar_reporte3/<string:Codigo_alu>')
def editar_reporte3(Codigo_alu):
    lista_alumno = buscar_reporte3(Codigo_alu)
    return render_template('editar_reporte3.html', dato=lista_alumno[0])


@app.route('/update_reporte3/<Codigo_alu>', methods=['POST'])
def update_reporte3(Codigo_alu):
    if request.method == 'POST':
        Codigo_alu = request.form['Codigo_alu']
        Alumno = request.form['Alumno']
        Curso = request.form['Curso']
        actualizar_reporte3(Codigo_alu, Alumno, Curso)
        return redirect(url_for('reporte3'))


def actualizar_reporte3(Codigo_alu, Alumno, Curso):
    con = conexion()
    with con.cursor() as c:
        c.execute("call actualizar_reporte3(%s,%s,%s)",
                  (Codigo_alu, Alumno, Curso))
    con.commit()
    con.close()


def buscar_reporte3(Codigo_alu):
    con = conexion()
    alumno_lista = []
    with con.cursor() as c:
        c.execute("call buscar_reporte3(%s)", (Codigo_alu))
        alumno_lista = c.fetchall()
    con.close()
    return alumno_lista


# 4 Visualizar los estudiantes que tengan más de un consolidado de notas de la I.E Trilce para saber quiénes llevan más de un año en la I.E Trilce


@app.route('/reporte4')
def reporte4():
    lista_alumno = reporte4_1()
    return render_template('reporte4.html', datos=lista_alumno)


def reporte4_1():
    con = conexion()
    alumno_lista = []
    with con.cursor() as c:
        c.execute('call reporte4();')
        alumno_lista = c.fetchall()
    con.close()
    return alumno_lista


# 5 Visualizar el estudiante con mayor nota en el 1er, 2do, 3er y 4to bimestre para poder saber cuál es el estudiante de excelencia en el salón


@app.route('/reporte5')
def reporte5():
    lista_alumno = reporte5_1()
    return render_template('reporte5.html', datos=lista_alumno)


def reporte5_1():
    con = conexion()
    alumno_lista = []
    with con.cursor() as c:
        c.execute('call reporte5();')
        alumno_lista = c.fetchall()
    con.close()
    return alumno_lista

# 6 Mostrar a los alumnos con menor promedio de area, para ver los peores puestos y tomar medidas al respecto


@app.route('/reporte6')
def reporte6():
    lista_alumno = reporte6_1()
    return render_template('reporte6.html', datos=lista_alumno)


def reporte6_1():
    con = conexion()
    alumno_lista = []
    with con.cursor() as c:
        c.execute('call reporte6();')
        alumno_lista = c.fetchall()
    con.close()
    return alumno_lista

# 7 Mostrar a los alumnos con menor promedio de area, para ver los peores puestos y tomar medidas al respecto


@app.route('/reporte7')
def reporte7():
    lista_alumno = reporte7_1()
    return render_template('reporte7.html', datos=lista_alumno)


def reporte7_1():
    con = conexion()
    alumno_lista = []
    with con.cursor() as c:
        c.execute('call reporte7();')
        alumno_lista = c.fetchall()
    con.close()
    return alumno_lista

# 8 Mostrar a los alumnos con menor promedio de area, para ver los peores puestos y tomar medidas al respecto


@app.route('/reporte8')
def reporte8():
    lista_alumno = reporte8_1()
    return render_template('reporte8.html', datos=lista_alumno)


def reporte8_1():
    con = conexion()
    alumno_lista = []
    with con.cursor() as c:
        c.execute('call reporte8();')
        alumno_lista = c.fetchall()
    con.close()
    return alumno_lista




if __name__ == "__main__":
    app.run(port=5000, debug=True)
