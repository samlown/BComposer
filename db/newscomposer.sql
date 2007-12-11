-- phpMyAdmin SQL Dump
-- version 2.8.1
-- http://www.phpmyadmin.net
-- 
-- Host: localhost
-- Generation Time: Jun 16, 2006 at 01:45 PM
-- Server version: 4.1.12
-- PHP Version: 5.0.5-2ubuntu1.2
-- 
-- Database: `newscomposer`
-- 

-- --------------------------------------------------------

-- 
-- Table structure for table `bulletins`
-- 

CREATE TABLE `bulletins` (
  `id` int(11) NOT NULL auto_increment,
  `project_id` int(11) NOT NULL default '0',
  `templet_id` int(11) NOT NULL default '0',
  `title` varchar(255) NOT NULL default '',
  `notes` text,
  `date_released` datetime default NULL,
  `date_updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

-- 
-- Table structure for table `entries`
-- 

CREATE TABLE `entries` (
  `id` int(11) NOT NULL auto_increment,
  `section_id` int(11) NOT NULL default '0',
  `title` text NOT NULL,
  `style` varchar(50) default NULL,
  `body` text,
  `image_link` varchar(255) default NULL,
  `image_text` text,
  `link` varchar(255) default NULL,
  `link_text` varchar(255) default NULL,
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `date_updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

-- 
-- Table structure for table `projects`
-- 

CREATE TABLE `projects` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(50) NOT NULL default '',
  `desciption` text,
  `date_updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

-- 
-- Table structure for table `sections`
-- 

CREATE TABLE `sections` (
  `id` int(11) NOT NULL auto_increment,
  `bulletin_id` int(11) NOT NULL default '0',
  `name` varchar(255) NOT NULL default '',
  `title` text,
  `style` varchar(50) default NULL,
  `description` text,
  `type` varchar(10) default NULL,
  `link` varchar(255) default NULL,
  `link_text` varchar(255) default NULL,
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `date_updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

-- 
-- Table structure for table `templet_layouts`
-- 

CREATE TABLE `templet_layouts` (
  `id` int(11) NOT NULL auto_increment,
  `templet_id` int(11) NOT NULL default '0',
  `name` varchar(30) NOT NULL default '',
  `data` text NOT NULL,
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `date_updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

-- 
-- Table structure for table `templets`
-- 

CREATE TABLE `templets` (
  `id` int(11) NOT NULL auto_increment,
  `project_id` int(11) NOT NULL default '0',
  `name` varchar(50) NOT NULL default '',
  `description` text NOT NULL,
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `date_updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

-- 
-- Table structure for table `users`
-- 

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `project_id` int(11) NOT NULL default '0',
  `name` varchar(30) NOT NULL default '',
  `password` varchar(50) NOT NULL default '',
  `description` text NOT NULL,
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `date_updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
