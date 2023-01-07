DROP DATABASE IF EXISTS `mailserver`;
CREATE DATABASE `mailserver`;
USE `mailserver`;

CREATE TABLE `virtual_domains` (
    `id` int(11) NOT NULL auto_increment,
    `name` varchar(50) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `virtual_users` (
    `id` int(11) NOT NULL auto_increment,
    `domain_id` int(11) NOT NULL,
    `password` varchar(106) NOT NULL,
    `email` varchar(100) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `email` (`email`),
    FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `virtual_aliases` (
    `id` int(11) NOT NULL auto_increment,
    `domain_id` int(11) NOT NULL,
    `source` varchar(100) NOT NULL,
    `destination` varchar(100) NOT NULL,
    PRIMARY KEY (`id`),
    FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Default user --
INSERT INTO mailserver.virtual_domains (name) VALUES ('smtp-sc.domain');

INSERT INTO mailserver.virtual_users (domain_id, password , email)
VALUES ('1', '$6$.yZhFbwHvpxiCx3.$eNrRN.eSs8I6AeKRTOvgPymo3fvXf.e4W4J4OpzlwUxkaRahH5pLDJv40Ms.T5bH5ncFpNcpY3vLTUsVa/6HS1', 'hieplnc.m20ict@smtp-sc.domain');

INSERT INTO mailserver.virtual_users (domain_id, password , email)
VALUES ('1', '$6$.yZhFbwHvpxiCx3.$eNrRN.eSs8I6AeKRTOvgPymo3fvXf.e4W4J4OpzlwUxkaRahH5pLDJv40Ms.T5bH5ncFpNcpY3vLTUsVa/6HS1', 'lenhuchuhiep99@smtp-sc.domain');

INSERT INTO mailserver.virtual_users (domain_id, password , email)
VALUES ('1', '$6$.yZhFbwHvpxiCx3.$eNrRN.eSs8I6AeKRTOvgPymo3fvXf.e4W4J4OpzlwUxkaRahH5pLDJv40Ms.T5bH5ncFpNcpY3vLTUsVa/6HS1', 'admin@smtp-sc.domain');
