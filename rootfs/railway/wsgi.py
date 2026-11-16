# Indico's WSGI app, plus /healthz for Railway's health check. Indico answers
# 404 to any host other than BASE_URL's, and the health probe uses its own host.
from indico.web.flask.app import make_app

_indico = make_app()


def application(environ, start_response):
    if environ.get('PATH_INFO') == '/healthz':
        start_response('200 OK', [('Content-Type', 'text/plain'), ('Cache-Control', 'no-store')])
        return [b'ok\n']
    return _indico(environ, start_response)
