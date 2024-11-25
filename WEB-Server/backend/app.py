from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_jwt_extended import JWTManager, create_access_token
from models import db, System, Service, User
import ansible_runner
from datetime import datetime, timedelta

app = Flask(__name__)
CORS(app)

# Konfiguration
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://user:pass@localhost/uptime'
app.config['JWT_SECRET_KEY'] = 'your-secret-key'  # In Produktion sicher speichern!
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(days=1)

jwt = JWTManager(app)
db.init_app(app)

@app.route('/api/auth/login', methods=['POST'])
def login():
    data = request.get_json()
    user = User.query.filter_by(username=data['username']).first()
    
    if user and user.check_password(data['password']):
        access_token = create_access_token(identity=user.id)
        return jsonify({'token': access_token}), 200
    
    return jsonify({'error': 'Invalid credentials'}), 401

@app.route('/api/systems', methods=['GET'])
@jwt_required()
def get_systems():
    systems = System.query.all()
    return jsonify([system.to_dict() for system in systems])

@app.route('/api/systems', methods=['POST'])
@jwt_required()
def add_system():
    data = request.get_json()
    
    # Ansible Playbook für Server-Setup ausführen
    result = ansible_runner.run(
        private_data_dir='ansible',
        playbook='server_setup.yml',
        extravars={
            'server_ip': data['ip'],
            'ssh_key': data['ssh_key']
        }
    )
    
    if result.status == 'successful':
        system = System(
            name=data['name'],
            ip=data['ip'],
            icon=data['icon']
        )
        db.session.add(system)
        db.session.commit()
        return jsonify(system.to_dict()), 201
    
    return jsonify({'error': 'Server setup failed'}), 400

@app.route('/api/services', methods=['GET'])
@jwt_required()
def get_services():
    services = Service.query.all()
    return jsonify([service.to_dict() for service in services])

@app.route('/api/services/discover', methods=['POST'])
@jwt_required()
def discover_services():
    system_id = request.json['system_id']
    system = System.query.get(system_id)
    
    # Service-Discovery durchführen
    discovered = discover_system_services(system.ip)
    
    for service_data in discovered:
        service = Service(
            name=service_data['name'],
            type=service_data['type'],
            port=service_data['port'],
            system_id=system_id
        )
        db.session.add(service)
    
    db.session.commit()
    return jsonify({'message': 'Services discovered'}), 200

if __name__ == '__main__':
    app.run(debug=True) 