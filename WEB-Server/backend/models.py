from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash

db = SQLAlchemy()

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password_hash = db.Column(db.String(120), nullable=False)
    
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
        
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

class System(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), nullable=False)
    ip = db.Column(db.String(15), nullable=False)
    icon = db.Column(db.String(50))
    is_online = db.Column(db.Boolean, default=True)
    services = db.relationship('Service', backref='system', lazy=True)
    
    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'ip': self.ip,
            'icon': self.icon,
            'is_online': self.is_online,
            'services': [s.to_dict() for s in self.services]
        }

class Service(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), nullable=False)
    type = db.Column(db.String(50))
    port = db.Column(db.Integer)
    is_online = db.Column(db.Boolean, default=True)
    system_id = db.Column(db.Integer, db.ForeignKey('system.id'))
    
    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'type': self.type,
            'port': self.port,
            'is_online': self.is_online
        } 