import os
from datetime import datetime
from flask import Flask, request, redirect, url_for, render_template_string, session, flash
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)
app.secret_key = os.environ.get("FLASK_SECRET_KEY", "db_health_demo_secret_2026_estable")

DB_HOST = os.environ.get("DB_HOST", "localhost")
DB_USER = os.environ.get("DB_USER", "root")
DB_PASS = os.environ.get("DB_PASS", "1234")
DB_NAME = os.environ.get("DB_NAME", "db_health")

CLAVES_POR_ROL = {
    "paciente": os.environ.get("CLAVE_PACIENTE", "pac123"),
    "medico": os.environ.get("CLAVE_MEDICO", "med123"),
}

ILUSTRACION_MEDICA_SVG = """
<svg viewBox="0 0 360 190" width="100%" height="auto" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Ilustración médica DB-Health">
  <defs>
    <linearGradient id="bgCard" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#e0f2fe" />
      <stop offset="100%" stop-color="#f0fdf4" />
    </linearGradient>
    <linearGradient id="pulseGrad" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#0284c7" />
      <stop offset="100%" stop-color="#0d9488" />
    </linearGradient>
  </defs>
  <rect x="6" y="6" width="348" height="178" rx="18" fill="url(#bgCard)" stroke="#bae6fd" stroke-width="2" />
  <circle cx="292" cy="48" r="30" fill="#0284c7" opacity="0.12" />
  <circle cx="66" cy="148" r="24" fill="#0d9488" opacity="0.12" />

  <rect x="158" y="32" width="44" height="14" rx="5" fill="#0284c7" />
  <rect x="173" y="18" width="14" height="42" rx="5" fill="#0284c7" />

  <rect x="52" y="78" width="256" height="78" rx="14" fill="#ffffff" stroke="#cbd5e1" stroke-width="1.5" />
  <polyline
    fill="none"
    stroke="url(#pulseGrad)"
    stroke-width="4"
    stroke-linecap="round"
    stroke-linejoin="round"
    points="72,118 110,118 126,96 144,140 164,88 184,132 200,118 286,118"
  />
  <circle cx="286" cy="118" r="6" fill="#0d9488" />
</svg>
"""


def get_conn(database=DB_NAME):
    return mysql.connector.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        database=database,
    )


def nombre_completo(row):
    partes = [
        row.get("primer_nombre") or "",
        row.get("segundo_nombre") or "",
        row.get("primer_apellido") or "",
        row.get("segundo_apellido") or "",
    ]
    return " ".join(p.strip() for p in partes if p and p.strip())


def usuario_valido_en_bd(rol, identificacion):
    if not rol or not identificacion:
        return False
    try:
        conn = get_conn()
        cur = conn.cursor()
        if rol == "paciente":
            cur.execute("SELECT 1 FROM paciente WHERE identificacion = %s LIMIT 1", (identificacion,))
        elif rol == "medico":
            cur.execute("SELECT 1 FROM medico WHERE identificacion = %s LIMIT 1", (identificacion,))
        else:
            cur.close()
            conn.close()
            return False
        existe = cur.fetchone() is not None
        cur.close()
        conn.close()
        return existe
    except Error:
        return False


HTML_BASE = """
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>DB-Health | Portal Clínico</title>
  <style>
    :root {
      --bg: #f4f7fb;
      --surface: #ffffff;
      --ink: #0f172a;
      --muted: #64748b;
      --line: #e2e8f0;
      --primary: #0284c7;
      --primary-dark: #0369a1;
      --teal: #0d9488;
    }
    * { box-sizing: border-box; font-family: "Segoe UI", system-ui, -apple-system, Roboto, sans-serif; }
    body { margin: 0; background: var(--bg); color: var(--ink); line-height: 1.45; }

    header {
      background: linear-gradient(90deg, #0f172a 0%, #1e293b 100%);
      color: #fff;
      padding: 14px 28px;
      display: flex;
      flex-wrap: wrap;
      justify-content: space-between;
      align-items: center;
      gap: 14px;
      box-shadow: 0 4px 14px rgba(15, 23, 42, 0.14);
      position: sticky;
      top: 0;
      z-index: 20;
    }
    .brand { display: flex; align-items: center; gap: 10px; }
    .brand-icon {
      width: 34px; height: 34px; border-radius: 10px;
      background: linear-gradient(135deg, #0284c7, #0d9488);
      display: grid; place-items: center; font-weight: 800; font-size: 1.1rem;
    }
    header h1 { margin: 0; font-size: 1.22rem; letter-spacing: -0.01em; }
    .badge {
      background: rgba(14, 165, 233, 0.2);
      border: 1px solid rgba(125, 211, 252, 0.4);
      color: #bae6fd;
      padding: 3px 10px;
      border-radius: 999px;
      font-size: 0.76rem;
      font-weight: 600;
    }
    .nav-group { display: flex; flex-wrap: wrap; align-items: center; gap: 10px; }

    .btn {
      background: var(--primary);
      color: #fff;
      border: none;
      padding: 9px 16px;
      border-radius: 9px;
      cursor: pointer;
      font-weight: 600;
      font-size: 0.9rem;
      text-decoration: none;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      gap: 6px;
      transition: background 0.18s ease, transform 0.12s ease;
    }
    .btn:hover { background: var(--primary-dark); transform: translateY(-1px); }
    .btn-teal { background: var(--teal); }
    .btn-teal:hover { background: #0f766e; }
    .btn-secondary { background: #334155; }
    .btn-secondary:hover { background: #1e293b; }
    .btn-outline {
      background: rgba(255, 255, 255, 0.06);
      color: #f8fafc;
      border: 1px solid rgba(148, 163, 184, 0.45);
      padding: 7px 13px;
      border-radius: 9px;
      cursor: pointer;
      font-weight: 600;
      font-size: 0.88rem;
      text-decoration: none;
      display: inline-block;
    }
    .btn-outline:hover { background: rgba(255, 255, 255, 0.14); }

    .container { max-width: 1180px; margin: 26px auto 44px; padding: 0 18px; display: grid; gap: 22px; }
    .login-wrap { max-width: 490px; width: 100%; margin: 6px auto; }

    .card {
      background: var(--surface);
      border: 1px solid var(--line);
      border-radius: 14px;
      padding: 22px 24px;
      box-shadow: 0 4px 16px rgba(15, 23, 42, 0.04);
    }
    .card h2 {
      margin: 0 0 14px 0;
      font-size: 1.15rem;
      color: var(--ink);
      border-bottom: 1px solid var(--line);
      padding-bottom: 10px;
    }

    .hero {
      background: linear-gradient(125deg, #0f172a 0%, #0369a1 58%, #0d9488 100%);
      color: #fff;
      border-radius: 18px;
      padding: 30px;
      display: grid;
      grid-template-columns: 1.25fr 0.85fr;
      align-items: center;
      gap: 24px;
      box-shadow: 0 12px 26px rgba(3, 105, 161, 0.18);
    }
    @media (max-width: 820px) {
      .hero { grid-template-columns: 1fr; padding: 24px 20px; }
    }
    .hero h2 { margin: 0 0 10px 0; font-size: 1.75rem; color: #fff; line-height: 1.2; }
    .hero p { margin: 0 0 20px 0; color: #e0f2fe; font-size: 0.98rem; }

    .grid-2 { display: grid; grid-template-columns: repeat(auto-fit, minmax(340px, 1fr)); gap: 22px; }

    label { display: block; font-size: 0.85rem; font-weight: 600; margin-bottom: 5px; color: #334155; }
    input, select, textarea {
      width: 100%;
      padding: 10px 12px;
      border: 1px solid #cbd5e1;
      border-radius: 9px;
      margin-bottom: 14px;
      font-size: 0.92rem;
      background: #fff;
      color: var(--ink);
    }
    input:focus, select:focus, textarea:focus {
      outline: none;
      border-color: var(--primary);
      box-shadow: 0 0 0 3px rgba(2, 132, 199, 0.15);
    }

    .table-wrap { overflow-x: auto; }
    table { width: 100%; border-collapse: collapse; font-size: 0.89rem; }
    th, td { text-align: left; padding: 10px 12px; border-bottom: 1px solid var(--line); vertical-align: top; }
    th { background: #f8fafc; color: #334155; font-weight: 700; white-space: nowrap; }
    tr:hover td { background: #f8fafc; }

    .status {
      display: inline-block;
      padding: 3px 9px;
      border-radius: 999px;
      font-size: 0.78rem;
      font-weight: 700;
      background: #e0f2fe;
      color: #0369a1;
    }
    .status-atendida { background: #dcfce7; color: #166534; }
    .status-cancelada { background: #fee2e2; color: #991b1b; }

    .flash { padding: 11px 15px; border-radius: 10px; font-weight: 600; font-size: 0.9rem; }
    .flash-ok { background: #dcfce7; color: #166534; border: 1px solid #86efac; }
    .flash-err { background: #fee2e2; color: #991b1b; border: 1px solid #fca5a5; }
    .hint { font-size: 0.8rem; color: var(--muted); margin-top: -8px; margin-bottom: 14px; }
    .session-pill {
      background: rgba(255, 255, 255, 0.12);
      padding: 6px 12px;
      border-radius: 999px;
      font-size: 0.85rem;
    }
  </style>
</head>
<body>
  <header>
    <div class="nav-group">
      <div class="brand">
        <div class="brand-icon">+</div>
        <h1>DB-Health <span class="badge">Portal Clínico</span></h1>
      </div>
      <a class="btn-outline" href="{{ url_for('inicio') }}">Inicio</a>
      {% if session.get("rol") == "paciente" %}
        <a class="btn-outline" href="{{ url_for('panel_paciente') }}">Mi Panel</a>
      {% elif session.get("rol") == "medico" %}
        <a class="btn-outline" href="{{ url_for('panel_medico') }}">Agenda Médica</a>
      {% endif %}
    </div>

    {% if session.get("rol") %}
      <div class="nav-group">
        <span class="session-pill">
          Rol: <strong>{{ session.get("rol")|upper }}</strong> · ID: <strong>{{ session.get("identificacion") }}</strong>
        </span>
        <a class="btn btn-secondary" href="{{ url_for('cambiar_rol') }}">Cambiar rol</a>
      </div>
    {% endif %}
  </header>

  <div class="container">
    {% with messages = get_flashed_messages(with_categories=true) %}
      {% if messages %}
        {% for cat, msg in messages %}
          <div class="flash {{ 'flash-ok' if cat == 'ok' else 'flash-err' }}">{{ msg }}</div>
        {% endfor %}
      {% endif %}
    {% endwith %}

    {{ contenido|safe }}
  </div>
</body>
</html>
"""

INICIO_HTML = """
<div class="hero">
  <div>
    <h2>Atención clínica ágil y organizada con DB-Health</h2>
    <p>
      Gestiona citas médicas, consulta tu historia clínica y observaciones, revisa fórmulas médicas
      o administra la agenda asistencial desde una plataforma conectada a MariaDB.
    </p>
    <div class="nav-group">
      {% if session.get("rol") == "paciente" %}
        <a class="btn btn-teal" href="{{ url_for('panel_paciente') }}">Abrir mi panel de Paciente</a>
        <a class="btn btn-secondary" href="{{ url_for('cambiar_rol') }}">Cambiar de rol</a>
      {% elif session.get("rol") == "medico" %}
        <a class="btn btn-teal" href="{{ url_for('panel_medico') }}">Abrir mi agenda de Médico</a>
        <a class="btn btn-secondary" href="{{ url_for('cambiar_rol') }}">Cambiar de rol</a>
      {% else %}
        <a class="btn btn-teal" href="{{ url_for('login') }}">Ingresar al sistema</a>
      {% endif %}
    </div>
  </div>
  <div>
    {{ ilustracion|safe }}
  </div>
</div>

<div class="grid-2">
  <div class="card">
    <h2>Módulo Paciente</h2>
    <p style="color: var(--muted); margin-top: 0;">
      Solicita nuevas citas médicas, consulta el estado de tus consultas, revisa tu historia clínica
      y observaciones y visualiza tus fórmulas médicas activas.
    </p>
    <a class="btn" href="{{ url_for('login') }}">Ingresar al portal</a>
  </div>

  <div class="card">
    <h2>Módulo Médico</h2>
    <p style="color: var(--muted); margin-top: 0;">
      Consulta las citas asignadas, actualiza su estado de atención y registra fórmulas médicas
      con dosis e indicaciones de tratamiento.
    </p>
    <a class="btn btn-teal" href="{{ url_for('login') }}">Ingresar al portal</a>
  </div>
</div>
"""

LOGIN_HTML = """
<div class="login-wrap">
  <div class="card">
    <div style="margin-bottom: 12px;">
      {{ ilustracion|safe }}
    </div>
    <h2>Inicio de Sesión</h2>
    <form method="POST" action="{{ url_for('login') }}">
      <label>Rol</label>
      <select id="rolSelect" name="rol" required onchange="actualizarUsuarios()">
        <option value="paciente">Paciente</option>
        <option value="medico">Médico</option>
      </select>

      <label>Usuario</label>
      <select id="usuarioSelect" name="identificacion" required></select>

      <label>Clave de acceso</label>
      <input type="password" name="clave" placeholder="Ingresa la clave del rol seleccionado" required />
      <div class="hint">Claves demo — Paciente: <code>pac123</code> · Médico: <code>med123</code></div>

      <button class="btn" style="width: 100%;" type="submit">Ingresar</button>
    </form>
  </div>
</div>

<script>
  const USUARIOS_POR_ROL = {
    paciente: {{ pacientes|tojson }},
    medico: {{ medicos|tojson }}
  };

  function actualizarUsuarios() {
    const rol = document.getElementById("rolSelect").value;
    const select = document.getElementById("usuarioSelect");
    const lista = USUARIOS_POR_ROL[rol] || [];
    select.innerHTML = "";
    lista.forEach((u) => {
      const opt = document.createElement("option");
      opt.value = u.identificacion;
      opt.textContent = `${u.identificacion} - ${u.nombre}`;
      select.appendChild(opt);
    });
  }

  actualizarUsuarios();
</script>
"""

PACIENTE_HTML = """
<div class="grid-2">
  <div class="card">
    <h2>Solicitar Cita Médica</h2>
    <form method="POST" action="{{ url_for('crear_cita') }}">
      <label>Médico</label>
      <select name="identificacion_medico" required>
        {% for m in medicos %}
          <option value="{{ m.identificacion }}">{{ m.nombre }} ({{ m.identificacion }})</option>
        {% endfor %}
      </select>

      <label>Consultorio</label>
      <select name="numero_consultorio" required>
        {% for c in consultorios %}
          <option value="{{ c.numero_consultorio }}">Consultorio {{ c.numero_consultorio }} - Hospital {{ c.codigo_hospital }} (Piso {{ c.piso }})</option>
        {% endfor %}
      </select>

      <label>Administrativo que asigna</label>
      <select name="identificacion_administrativo" required>
        {% for a in administrativos %}
          <option value="{{ a.identificacion }}">{{ a.nombre }} ({{ a.identificacion }})</option>
        {% endfor %}
      </select>

      <label>Fecha y hora programada</label>
      <input type="datetime-local" name="fecha_hora_programada" value="{{ fecha_default }}" required />

      <label>Motivo de consulta / Examen</label>
      <textarea name="motivo_consulta" rows="2" placeholder="Ej. Control general o examen de laboratorio"></textarea>

      <button class="btn" type="submit">Agendar Cita</button>
    </form>
  </div>

  <div class="card">
    <h2>Historia Clínica y Exámenes / Observaciones</h2>
    {% if historias %}
      <div class="table-wrap">
        <table>
          <thead>
            <tr><th>Historia</th><th>Fecha</th><th>Diagnóstico</th><th>Observaciones / Exámenes</th></tr>
          </thead>
          <tbody>
            {% for h in historias %}
              <tr>
                <td>{{ h.consecutivo_historia }}</td>
                <td>{{ h.fecha_apertura }}</td>
                <td><strong>{{ h.diagnostico_principal }}</strong></td>
                <td>{{ h.observaciones or "Sin observaciones" }}</td>
              </tr>
            {% endfor %}
          </tbody>
        </table>
      </div>
    {% else %}
      <p style="color: var(--muted);">No hay registros de historia clínica para este paciente.</p>
    {% endif %}
  </div>
</div>

<div class="card">
  <h2>Mis Citas Médicas</h2>
  <div class="table-wrap">
    <table>
      <thead>
        <tr><th>Consecutivo</th><th>Fecha/Hora</th><th>Médico</th><th>Consultorio</th><th>Estado</th><th>Motivo</th></tr>
      </thead>
      <tbody>
        {% for c in citas %}
          {% set est = (c.estado_cita or '')|lower %}
          <tr>
            <td>#{{ c.consecutivo_cita }}</td>
            <td>{{ c.fecha_hora_programada }}</td>
            <td>{{ c.identificacion_medico }}</td>
            <td>{{ c.numero_consultorio }}</td>
            <td>
              <span class="status {{ 'status-atendida' if est == 'atendida' else ('status-cancelada' if est == 'cancelada' else '') }}">
                {{ c.estado_cita }}
              </span>
            </td>
            <td>{{ c.motivo_consulta or "-" }}</td>
          </tr>
        {% endfor %}
      </tbody>
    </table>
  </div>
</div>

<div class="card">
  <h2>Mis Fórmulas Médicas</h2>
  <div class="table-wrap">
    <table>
      <thead>
        <tr><th>Cita</th><th>Medicamento</th><th>Dosis Indicada</th><th>Duración</th></tr>
      </thead>
      <tbody>
        {% for f in formulas %}
          <tr>
            <td>#{{ f.consecutivo_cita }}</td>
            <td><strong>{{ f.codigo_medicamento }}</strong></td>
            <td>{{ f.dosis_indicada }}</td>
            <td>{{ f.duracion_tratamiento }}</td>
          </tr>
        {% endfor %}
      </tbody>
    </table>
  </div>
</div>
"""

MEDICO_HTML = """
<div class="grid-2">
  <div class="card">
    <h2>Actualizar Estado de Cita</h2>
    <form method="POST" action="{{ url_for('actualizar_cita') }}">
      <label>Consecutivo de Cita</label>
      <select name="consecutivo_cita" required>
        {% for c in citas %}
          <option value="{{ c.consecutivo_cita }}">Cita #{{ c.consecutivo_cita }} - Pac: {{ c.identificacion_paciente }} ({{ c.estado_cita }})</option>
        {% endfor %}
      </select>

      <label>Nuevo Estado de Cita</label>
      <select name="estado_cita" required>
        <option value="Programada">Programada</option>
        <option value="Confirmada">Confirmada</option>
        <option value="Atendida">Atendida</option>
        <option value="Cancelada">Cancelada</option>
      </select>

      <button class="btn" type="submit">Guardar Estado</button>
    </form>
  </div>

  <div class="card">
    <h2>Emitir Fórmula Médica</h2>
    <form method="POST" action="{{ url_for('emitir_formula') }}">
      <label>Consecutivo de Cita</label>
      <select name="consecutivo_cita" required>
        {% for c in citas %}
          <option value="{{ c.consecutivo_cita }}">Cita #{{ c.consecutivo_cita }} - Pac: {{ c.identificacion_paciente }}</option>
        {% endfor %}
      </select>

      <label>Medicamento</label>
      <select name="codigo_medicamento" required>
        {% for med in medicamentos %}
          <option value="{{ med.codigo_medicamento }}">{{ med.codigo_medicamento }} - {{ med.nombre_comercial }} ({{ med.concentracion }})</option>
        {% endfor %}
      </select>

      <label>Dosis Indicada</label>
      <input type="text" name="dosis_indicada" placeholder="Ej. 500 mg cada 8 horas" required />

      <label>Duración del Tratamiento</label>
      <input type="text" name="duracion_tratamiento" placeholder="Ej. 7 días" required />

      <button class="btn btn-teal" type="submit">Registrar Fórmula</button>
    </form>
  </div>
</div>

<div class="card">
  <h2>Agenda de Citas del Médico</h2>
  <div class="table-wrap">
    <table>
      <thead>
        <tr><th>Consecutivo</th><th>Fecha/Hora</th><th>Paciente</th><th>Consultorio</th><th>Estado</th><th>Motivo</th></tr>
      </thead>
      <tbody>
        {% for c in citas %}
          {% set est = (c.estado_cita or '')|lower %}
          <tr>
            <td>#{{ c.consecutivo_cita }}</td>
            <td>{{ c.fecha_hora_programada }}</td>
            <td>{{ c.identificacion_paciente }}</td>
            <td>{{ c.numero_consultorio }}</td>
            <td>
              <span class="status {{ 'status-atendida' if est == 'atendida' else ('status-cancelada' if est == 'cancelada' else '') }}">
                {{ c.estado_cita }}
              </span>
            </td>
            <td>{{ c.motivo_consulta or "-" }}</td>
          </tr>
        {% endfor %}
      </tbody>
    </table>
  </div>
</div>
"""


def render_page(inner_html):
    return render_template_string(HTML_BASE, contenido=inner_html)


@app.route("/", methods=["GET"])
def inicio():
    inner = render_template_string(INICIO_HTML, ilustracion=ILUSTRACION_MEDICA_SVG)
    return render_page(inner)


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        rol = (request.form.get("rol") or "").strip().lower()
        identificacion = (request.form.get("identificacion") or "").strip()
        clave = request.form.get("clave") or ""

        clave_esperada = CLAVES_POR_ROL.get(rol)
        if not clave_esperada or clave != clave_esperada:
            flash("Clave incorrecta para el rol seleccionado. Intenta nuevamente.", "err")
            return redirect(url_for("login"))

        if not usuario_valido_en_bd(rol, identificacion):
            flash("La identificación seleccionada no corresponde a un usuario válido de ese rol.", "err")
            return redirect(url_for("login"))

        session.clear()
        session["rol"] = rol
        session["identificacion"] = identificacion
        session["autenticado_en"] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        flash(f"Sesión iniciada como {rol} ({identificacion}).", "ok")
        return redirect(url_for("panel_paciente" if rol == "paciente" else "panel_medico"))

    pacientes = []
    medicos = []
    try:
        conn = get_conn()
        cur = conn.cursor(dictionary=True)

        cur.execute("""
            SELECT pa.identificacion, pe.primer_nombre, pe.segundo_nombre, pe.primer_apellido, pe.segundo_apellido
            FROM paciente pa
            JOIN persona pe ON pa.identificacion = pe.identificacion
        """)
        for r in cur.fetchall():
            pacientes.append({"identificacion": r["identificacion"], "nombre": nombre_completo(r) or r["identificacion"]})

        cur.execute("""
            SELECT me.identificacion, pe.primer_nombre, pe.segundo_nombre, pe.primer_apellido, pe.segundo_apellido
            FROM medico me
            JOIN persona pe ON me.identificacion = pe.identificacion
        """)
        for r in cur.fetchall():
            medicos.append({"identificacion": r["identificacion"], "nombre": nombre_completo(r) or r["identificacion"]})

        cur.close()
        conn.close()
    except Error as e:
        flash(f"Error cargando usuarios desde MariaDB: {e}", "err")

    inner = render_template_string(
        LOGIN_HTML,
        pacientes=pacientes,
        medicos=medicos,
        ilustracion=ILUSTRACION_MEDICA_SVG,
    )
    return render_page(inner)


@app.route("/cambiar-rol")
def cambiar_rol():
    session.clear()
    flash("Se cerró la sesión anterior. Verifica tu rol y clave para ingresar.", "ok")
    return redirect(url_for("login"))


@app.route("/paciente")
def panel_paciente():
    if session.get("rol") != "paciente" or not usuario_valido_en_bd("paciente", session.get("identificacion")):
        session.clear()
        flash("Debes iniciar sesión con un rol de Paciente válido.", "err")
        return redirect(url_for("login"))

    id_pac = session["identificacion"]
    medicos, consultorios, administrativos, citas, historias, formulas = [], [], [], [], [], []
    fecha_default = datetime.now().strftime("%Y-%m-%dT%H:%M")

    try:
        conn = get_conn()
        cur = conn.cursor(dictionary=True)

        cur.execute("""
            SELECT me.identificacion, pe.primer_nombre, pe.segundo_nombre, pe.primer_apellido, pe.segundo_apellido
            FROM medico me JOIN persona pe ON me.identificacion = pe.identificacion
        """)
        for r in cur.fetchall():
            medicos.append({"identificacion": r["identificacion"], "nombre": nombre_completo(r) or r["identificacion"]})

        cur.execute("SELECT numero_consultorio, codigo_hospital, piso FROM consultorio")
        consultorios = cur.fetchall()

        cur.execute("""
            SELECT ad.identificacion, pe.primer_nombre, pe.segundo_nombre, pe.primer_apellido, pe.segundo_apellido
            FROM personal_administrativo ad JOIN persona pe ON ad.identificacion = pe.identificacion
        """)
        for r in cur.fetchall():
            administrativos.append({"identificacion": r["identificacion"], "nombre": nombre_completo(r) or r["identificacion"]})

        cur.execute(
            "SELECT * FROM cita_medica WHERE identificacion_paciente = %s ORDER BY fecha_hora_programada DESC",
            (id_pac,),
        )
        citas = cur.fetchall()

        cur.execute(
            "SELECT * FROM historia_clinica WHERE identificacion_paciente = %s ORDER BY fecha_apertura DESC",
            (id_pac,),
        )
        historias = cur.fetchall()

        cur.execute("""
            SELECT p.consecutivo_cita, p.codigo_medicamento, p.dosis_indicada, p.duracion_tratamiento
            FROM prescripcion_cita_medicamento p
            JOIN cita_medica c ON p.consecutivo_cita = c.consecutivo_cita
            WHERE c.identificacion_paciente = %s
        """, (id_pac,))
        formulas = cur.fetchall()

        cur.close()
        conn.close()
    except Error as e:
        flash(f"Error consultando datos del paciente: {e}", "err")

    inner = render_template_string(
        PACIENTE_HTML,
        medicos=medicos,
        consultorios=consultorios,
        administrativos=administrativos,
        citas=citas,
        historias=historias,
        formulas=formulas,
        fecha_default=fecha_default,
    )
    return render_page(inner)


@app.route("/paciente/cita", methods=["POST"])
def crear_cita():
    if session.get("rol") != "paciente" or not usuario_valido_en_bd("paciente", session.get("identificacion")):
        session.clear()
        return redirect(url_for("login"))

    id_pac = session["identificacion"]
    id_med = request.form["identificacion_medico"]
    num_cons = int(request.form["numero_consultorio"])
    id_adm = request.form["identificacion_administrativo"]
    fecha_raw = request.form["fecha_hora_programada"]
    fecha_str = fecha_raw.replace("T", " ") + ":00" if len(fecha_raw) == 16 else fecha_raw
    motivo = request.form.get("motivo_consulta", "").strip()

    try:
        conn = get_conn()
        cur = conn.cursor()
        cur.execute("SELECT COALESCE(MAX(consecutivo_cita), 0) + 1 FROM cita_medica")
        nuevo_consecutivo = cur.fetchone()[0]

        cur.execute(
            """
            INSERT INTO cita_medica (
                consecutivo_cita, identificacion_paciente, identificacion_medico,
                numero_consultorio, identificacion_administrativo, fecha_hora_programada,
                estado_cita, motivo_consulta
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """,
            (nuevo_consecutivo, id_pac, id_med, num_cons, id_adm, fecha_str, "Programada", motivo),
        )
        conn.commit()
        cur.close()
        conn.close()
        flash(f"Cita #{nuevo_consecutivo} registrada correctamente.", "ok")
    except Error as e:
        flash(f"No se pudo agendar la cita: {e}", "err")

    return redirect(url_for("panel_paciente"))


@app.route("/medico")
def panel_medico():
    if session.get("rol") != "medico" or not usuario_valido_en_bd("medico", session.get("identificacion")):
        session.clear()
        flash("Debes iniciar sesión con un rol de Médico válido.", "err")
        return redirect(url_for("login"))

    id_med = session["identificacion"]
    citas, medicamentos = [], []

    try:
        conn = get_conn()
        cur = conn.cursor(dictionary=True)

        cur.execute(
            "SELECT * FROM cita_medica WHERE identificacion_medico = %s ORDER BY fecha_hora_programada DESC",
            (id_med,),
        )
        citas = cur.fetchall()

        cur.execute("SELECT codigo_medicamento, nombre_comercial, concentracion FROM medicamento")
        medicamentos = cur.fetchall()

        cur.close()
        conn.close()
    except Error as e:
        flash(f"Error cargando agenda médica: {e}", "err")

    inner = render_template_string(MEDICO_HTML, citas=citas, medicamentos=medicamentos)
    return render_page(inner)


@app.route("/medico/cita/estado", methods=["POST"])
def actualizar_cita():
    if session.get("rol") != "medico" or not usuario_valido_en_bd("medico", session.get("identificacion")):
        session.clear()
        return redirect(url_for("login"))

    consecutivo = int(request.form["consecutivo_cita"])
    nuevo_estado = request.form["estado_cita"]

    try:
        conn = get_conn()
        cur = conn.cursor()
        cur.execute(
            "UPDATE cita_medica SET estado_cita = %s WHERE consecutivo_cita = %s",
            (nuevo_estado, consecutivo),
        )
        conn.commit()
        cur.close()
        conn.close()
        flash(f"Cita #{consecutivo} actualizada a '{nuevo_estado}'.", "ok")
    except Error as e:
        flash(f"Error actualizando estado de la cita: {e}", "err")

    return redirect(url_for("panel_medico"))


@app.route("/medico/formula", methods=["POST"])
def emitir_formula():
    if session.get("rol") != "medico" or not usuario_valido_en_bd("medico", session.get("identificacion")):
        session.clear()
        return redirect(url_for("login"))

    consecutivo = int(request.form["consecutivo_cita"])
    cod_med = request.form["codigo_medicamento"]
    dosis = request.form["dosis_indicada"].strip()
    duracion = request.form["duracion_tratamiento"].strip()

    try:
        conn = get_conn()
        cur = conn.cursor()
        cur.execute(
            """
            INSERT INTO prescripcion_cita_medicamento (
                consecutivo_cita, codigo_medicamento, dosis_indicada, duracion_tratamiento
            ) VALUES (%s, %s, %s, %s)
            """,
            (consecutivo, cod_med, dosis, duracion),
        )
        conn.commit()
        cur.close()
        conn.close()
        flash(f"Fórmula médica registrada para la cita #{consecutivo}.", "ok")
    except Error as e:
        flash(f"Error registrando fórmula médica: {e}", "err")

    return redirect(url_for("panel_medico"))


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)