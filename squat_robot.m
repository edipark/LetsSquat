function robot = squat_robot(config, barbell, type)

    if type == "high"
        l = 0.7084;
    elseif type == "low"
        l = 0.6429;
    else
        error("invalid squat type")
    end

    robot = rigidBodyTree('DataFormat','column','MaxNumBodies',5);
    robot.Gravity = [0 -9.81 0];
        
    % Femur = 0.4703;
    % Tibia = 0.3691;
    % Body = 0.9076;
    % Foot = 0.26;
    % radius = 1.5*0.02;
    % Mass = 76.9;
    % Femur_m = 0.1 * Mass;
    % Tibia_m = 0.0465 * Mass;
    % Upper_m = 0.678 * Mass;
    % config = [0.4703, 0.3691, 0.9076, 0.26, 76.9];
    
    Femur = config(1);
    Tibia = config(2);
    Body = config(3);
    Foot = config(4);
    Mass = config(5);
    Femur_m = 0.1 * Mass;
    Tibia_m = 0.0465 * Mass;
    Upper_m = 0.678 * Mass;
    radius = 1.5*0.02;
    
    body = rigidBody('Foot');
    joint = rigidBodyJoint('Gnd', 'fixed');
    setFixedTransform(joint, trvec2tform([0, 0, 0]));
    body.Joint = joint;
    body.addVisual('Capsule', [radius, Foot], eul2tform([0,pi/2,0])*trvec2tform([0, 0, Foot/3]), 'FaceColor', [1 0 0]);
    addBody(robot, body, 'base');
    
    body = rigidBody('Tibia');
    joint = rigidBodyJoint('ankle', 'revolute');
    joint.PositionLimits = [0, 0.5*pi];
    setFixedTransform(joint,trvec2tform([0 0 0]));
    joint.JointAxis = [0 0 1];
    body.Joint = joint;
    body.Mass = Tibia_m;
    body.CenterOfMass = [0.433*Tibia 0 0];
    body.addVisual('Capsule', [radius, Tibia], eul2tform([0,pi/2,0])*trvec2tform([0, 0, Tibia/2]), 'FaceColor', [1 0 0]);
    addBody(robot, body, 'Foot');
    
    body = rigidBody('Femur');
    joint = rigidBodyJoint('knee','revolute');
    setFixedTransform(joint, trvec2tform([Tibia,0,0]));
    joint.JointAxis = [0 0 1];
    body.Joint = joint;
    body.Mass = Femur_m;
    body.CenterOfMass = [0.433*Femur 0 0];
    body.addVisual('Capsule', [radius, Femur], eul2tform([0,pi/2,0])*trvec2tform([0, 0, Femur/2]), 'FaceColor', [1 0 0]);
    addBody(robot, body, 'Tibia');
    
    body = rigidBody('Body');
    joint = rigidBodyJoint('hip','revolute');
    setFixedTransform(joint, trvec2tform([Femur, 0, 0]));
    body.Joint = joint;
    body.Mass = Upper_m;
    body.CenterOfMass = [0.626*Body 0 0];
    body.addVisual('Capsule', [radius, l*Body], eul2tform([0,pi/2,0])*trvec2tform([0, 0, l*Body/2]), 'FaceColor', [1 0 0]);
    addBody(robot, body, 'Femur');
    
    body = rigidBody('Body_Extended');
    joint = rigidBodyJoint('fix1','fixed');
    setFixedTransform(joint, trvec2tform([l*Body, 0, 0]));
    body.Joint = joint;
    body.Mass = barbell;
    body.CenterOfMass = [0 0 0];
    body.addVisual('Capsule', [radius, (0.75-l)*Body], eul2tform([0,pi/2,0])*trvec2tform([0, 0, (0.75-l)*Body/2]), 'FaceColor', [1 0 0]);
    addBody(robot, body, 'Body');
    
    body = rigidBody('Head');
    joint = rigidBodyJoint('fix2','fixed');
    setFixedTransform(joint, trvec2tform([(1-l)*Body - 0.08, 0, 0]));
    body.Joint = joint;
    body.addVisual('Sphere', 0.08, 'FaceColor', [1 0 0]);
    addBody(robot, body, 'Body_Extended');
end