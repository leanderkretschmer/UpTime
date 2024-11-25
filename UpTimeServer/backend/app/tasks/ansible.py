from celery import shared_task
import ansible_runner
import os

@shared_task
def deploy_system(system_id):
    from app.models import System
    from app import db
    
    system = System.query.get(system_id)
    if not system:
        return
    
    try:
        # Führe Ansible Playbook aus
        runner = ansible_runner.run(
            private_data_dir='/etc/ansible',
            playbook='setup_monitoring.yml',
            extravars={
                'target_host': system.hostname,
                'ssh_user': system.ssh_user
            }
        )
        
        if runner.status == 'successful':
            system.status = 'active'
        else:
            system.status = 'failed'
            
        db.session.commit()
        
    except Exception as e:
        system.status = 'failed'
        db.session.commit() 