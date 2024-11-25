from flask import Blueprint, request, jsonify
from app.models import System
from app.tasks.ansible import deploy_system
from flask_jwt_extended import jwt_required

systems_bp = Blueprint('systems', __name__)

@systems_bp.route('/systems', methods=['POST'])
@jwt_required()
def create_system():
    data = request.get_json()
    
    system = System(
        name=data['name'],
        hostname=data['hostname'],
        ssh_user=data['ssh_user'],
        ssh_key=data['ssh_key']
    )
    
    db.session.add(system)
    db.session.commit()
    
    # Starte Ansible Deployment async
    deploy_system.delay(system.id)
    
    return jsonify(system.to_dict()), 201 