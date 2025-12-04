function com_list = getAllCOM(robot, q)
    bodies = robot.BodyNames;
    com_list = zeros(length(bodies), 3);

    for i = 1:length(bodies)
        name = bodies{i};
        body = robot.Bodies{i};

        T = getTransform(robot, q, name);

        com_local = [body.CenterOfMass, 1]';

        com_world = T * com_local;

        com_list(i,:) = com_world(1:3)';
    end
end