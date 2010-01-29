CREATE TABLE `activity_sectors` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `activated` tinyint(1) default '1',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `addresses` (
  `id` int(11) NOT NULL auto_increment,
  `has_address_id` bigint(11) default NULL,
  `has_address_type` varchar(255) default NULL,
  `has_address_key` varchar(255) default NULL,
  `street_name` text,
  `country_name` varchar(255) default NULL,
  `city_name` varchar(255) default NULL,
  `zip_code` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `alarms` (
  `id` int(11) NOT NULL auto_increment,
  `event_id` bigint(11) default NULL,
  `title` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `email_to` varchar(255) default NULL,
  `action` varchar(255) default NULL,
  `do_alarm_before` bigint(11) default NULL,
  `duration` bigint(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `approachings` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `business_objects` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_business_objects_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8;

CREATE TABLE `calendars` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` bigint(11) default NULL,
  `name` varchar(255) default NULL,
  `title` varchar(255) default NULL,
  `color` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `checkings` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` bigint(11) default NULL,
  `employee_id` bigint(11) default NULL,
  `date` date default NULL,
  `absence_hours` bigint(11) default NULL,
  `absence_minutes` bigint(11) default NULL,
  `overtime_hours` bigint(11) default NULL,
  `overtime_minutes` bigint(11) default NULL,
  `absence_comment` text,
  `overtime_comment` text,
  `cancelled` tinyint(1) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `checklist_options` (
  `id` int(11) NOT NULL auto_increment,
  `checklist_id` bigint(11) default NULL,
  `parent_id` bigint(11) default NULL,
  `position` bigint(11) default NULL,
  `title` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `checklist_options_order_types` (
  `id` int(11) NOT NULL auto_increment,
  `checklist_option_id` bigint(11) default NULL,
  `order_type_id` bigint(11) default NULL,
  `activated` tinyint(1) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `checklist_responses` (
  `id` int(11) NOT NULL auto_increment,
  `checklist_option_id` bigint(11) default NULL,
  `product_id` bigint(11) default NULL,
  `answer` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `checklists` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `title` varchar(255) default NULL,
  `description` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cities` (
  `id` int(11) NOT NULL auto_increment,
  `country_id` bigint(11) default NULL,
  `name` varchar(255) default NULL,
  `zip_code` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `civilities` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `commercial_steps` (
  `id` int(11) NOT NULL auto_increment,
  `order_id` bigint(11) default NULL,
  `status` varchar(255) default NULL,
  `started_at` datetime default NULL,
  `finished_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `commodities` (
  `id` int(11) NOT NULL auto_increment,
  `supplier_id` bigint(11) default NULL,
  `commodity_category_id` bigint(11) default NULL,
  `name` varchar(255) default NULL,
  `fob_unit_price` float default NULL,
  `taxe_coefficient` float default NULL,
  `measure` float default NULL,
  `unit_mass` float default NULL,
  `enable` tinyint(1) default '1',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `commodities_inventories` (
  `id` int(11) NOT NULL auto_increment,
  `commodity_id` bigint(11) default NULL,
  `inventory_id` bigint(11) default NULL,
  `parent_commodity_category_id` bigint(11) default NULL,
  `commodity_category_id` bigint(11) default NULL,
  `unit_measure_id` bigint(11) default NULL,
  `supplier_id` bigint(11) default NULL,
  `name` varchar(255) default NULL,
  `commodity_category_name` varchar(255) default NULL,
  `parent_commodity_category_name` varchar(255) default NULL,
  `fob_unit_price` float default NULL,
  `taxe_coefficient` float default NULL,
  `measure` float default NULL,
  `unit_mass` float default NULL,
  `quantity` float default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `commodity_categories` (
  `id` int(11) NOT NULL auto_increment,
  `commodity_category_id` bigint(11) default NULL,
  `unit_measure_id` bigint(11) default NULL,
  `name` varchar(255) default NULL,
  `commodities_count` bigint(11) default '0',
  `enable` tinyint(1) default '1',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `configurations` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `value` text,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8;

CREATE TABLE `contact_numbers` (
  `id` int(11) NOT NULL auto_increment,
  `category` varchar(255) default NULL,
  `indicatif` varchar(255) default NULL,
  `number` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `contact_types` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `owner` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `contacts` (
  `id` int(11) NOT NULL auto_increment,
  `contact_type_id` bigint(11) default NULL,
  `first_name` varchar(255) default NULL,
  `last_name` varchar(255) default NULL,
  `job` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `gender` varchar(255) default NULL,
  `avatar_file_name` varchar(255) default NULL,
  `avatar_content_type` varchar(255) default NULL,
  `avatar_file_size` bigint(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `contacts_owners` (
  `id` int(11) NOT NULL auto_increment,
  `has_contact_id` bigint(11) default NULL,
  `has_contact_type` varchar(255) default NULL,
  `contact_id` bigint(11) default NULL,
  `contact_type_id` bigint(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `content_versions` (
  `id` int(11) NOT NULL auto_increment,
  `menu_id` bigint(11) default NULL,
  `content_id` bigint(11) default NULL,
  `contributor_id` bigint(11) default NULL,
  `title` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `text` text,
  `versioned_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `contents` (
  `id` int(11) NOT NULL auto_increment,
  `menu_id` bigint(11) default NULL,
  `author_id` bigint(11) default NULL,
  `title` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `text` text,
  `contributors` varchar(255) default NULL,
  `lock_version` bigint(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `countries` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `code` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `deliverers_interventions` (
  `id` int(11) NOT NULL auto_increment,
  `deliverer_id` bigint(11) default NULL,
  `intervention_id` bigint(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `delivery_note_items` (
  `id` int(11) NOT NULL auto_increment,
  `delivery_note_id` bigint(11) default NULL,
  `quote_item_id` bigint(11) default NULL,
  `report_type_id` bigint(11) default NULL,
  `quantity` bigint(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `delivery_notes` (
  `id` int(11) NOT NULL auto_increment,
  `order_id` bigint(11) default NULL,
  `creator_id` bigint(11) default NULL,
  `status` varchar(255) default NULL,
  `validated_on` date default NULL,
  `invalidated_on` date default NULL,
  `signed_on` date default NULL,
  `attachment_file_name` varchar(255) default NULL,
  `attachment_content_type` varchar(255) default NULL,
  `attachment_file_size` bigint(11) default NULL,
  `public_number` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `delivery_steps` (
  `id` int(11) NOT NULL auto_increment,
  `pre_invoicing_step_id` bigint(11) default NULL,
  `status` varchar(255) default NULL,
  `started_at` datetime default NULL,
  `finished_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `discard_types` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `discards` (
  `id` int(11) NOT NULL auto_increment,
  `delivery_note_item_id` bigint(11) default NULL,
  `discard_type_id` bigint(11) default NULL,
  `comments` text,
  `quantity` bigint(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `document_sending_methods` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `document_types` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `title` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_document_types_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;

CREATE TABLE `document_types_mime_types` (
  `document_type_id` bigint(11) default NULL,
  `mime_type_id` bigint(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `documents` (
  `id` int(11) NOT NULL auto_increment,
  `has_document_id` bigint(11) default NULL,
  `has_document_type` varchar(255) default NULL,
  `document_type_id` bigint(11) default NULL,
  `name` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `attachment_file_name` varchar(255) default NULL,
  `attachment_content_type` varchar(255) default NULL,
  `attachment_file_size` bigint(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `dunning_sending_methods` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `dunnings` (
  `id` int(11) NOT NULL auto_increment,
  `date` date default NULL,
  `comment` text,
  `has_dunning_type` varchar(255) default NULL,
  `cancelled` tinyint(1) default NULL,
  `creator_id` bigint(11) default NULL,
  `dunning_sending_method_id` bigint(11) default NULL,
  `has_dunning_id` bigint(11) default NULL,
  `cancelled_by_id` bigint(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `employee_states` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `active` tinyint(1) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `employees` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` bigint(11) default NULL,
  `service_id` bigint(11) default NULL,
  `civility_id` bigint(11) default NULL,
  `family_situation_id` bigint(11) default NULL,
  `first_name` varchar(255) default NULL,
  `last_name` varchar(255) default NULL,
  `social_security_number` varchar(255) default NULL,
  `qualification` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `society_email` varchar(255) default NULL,
  `birth_date` date default NULL,
  `avatar_file_name` varchar(255) default NULL,
  `avatar_content_type` varchar(255) default NULL,
  `avatar_file_size` bigint(11) default NULL,
  `avatar_updated_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `employees_jobs` (
  `job_id` bigint(11) default NULL,
  `employee_id` bigint(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `establishment_types` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `establishments` (
  `id` int(11) NOT NULL auto_increment,
  `establishment_type_id` bigint(11) default NULL,
  `customer_id` bigint(11) default NULL,
  `name` varchar(255) default NULL,
  `activated` tinyint(1) default '1',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `estimate_steps` (
  `id` int(11) NOT NULL auto_increment,
  `commercial_step_id` bigint(11) default NULL,
  `status` varchar(255) default NULL,
  `started_at` datetime default NULL,
  `finished_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `event_categories` (
  `id` int(11) NOT NULL auto_increment,
  `calendar_id` bigint(11) default NULL,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `events` (
  `id` int(11) NOT NULL auto_increment,
  `calendar_id` bigint(11) default NULL,
  `event_category_id` bigint(11) default NULL,
  `organizer_id` bigint(11) default NULL,
  `title` varchar(255) default NULL,
  `color` varchar(255) default NULL,
  `frequence` varchar(255) default NULL,
  `status` varchar(255) default NULL,
  `full_day` tinyint(1) NOT NULL default '0',
  `location` text,
  `description` text,
  `link` text,
  `interval` bigint(11) NOT NULL default '1',
  `count` bigint(11) default NULL,
  `by_day` varchar(255) default NULL,
  `by_month_day` varchar(255) default NULL,
  `by_month` varchar(255) default NULL,
  `start_at` datetime default NULL,
  `end_at` datetime default NULL,
  `until_date` date default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `exception_dates` (
  `id` int(11) NOT NULL auto_increment,
  `event_id` bigint(11) default NULL,
  `date` date default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `family_situations` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `features` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `title` varchar(255) default NULL,
  `version` varchar(255) default NULL,
  `dependencies` text,
  `conflicts` text,
  `installed` tinyint(1) NOT NULL default '0',
  `activated` tinyint(1) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;

CREATE TABLE `file_types` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `model_owner` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `file_types_mime_types` (
  `file_type_id` bigint(11) default NULL,
  `mime_type_id` bigint(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `graphic_document_types` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `graphic_item_spool_items` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` bigint(11) default NULL,
  `graphic_item_id` bigint(11) default NULL,
  `path` varchar(255) default NULL,
  `file_type` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `graphic_item_versions` (
  `id` int(11) NOT NULL auto_increment,
  `graphic_item_id` bigint(11) default NULL,
  `source_file_name` varchar(255) default NULL,
  `source_content_type` varchar(255) default NULL,
  `image_file_name` varchar(255) default NULL,
  `image_content_type` varchar(255) default NULL,
  `source_file_size` bigint(11) default NULL,
  `image_file_size` bigint(11) default NULL,
  `is_current_version` tinyint(1) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `graphic_items` (
  `id` int(11) NOT NULL auto_increment,
  `creator_id` bigint(11) default NULL,
  `graphic_unit_measure_id` bigint(11) default NULL,
  `graphic_document_type_id` bigint(11) default NULL,
  `mockup_type_id` bigint(11) default NULL,
  `order_id` bigint(11) default NULL,
  `press_proof_id` bigint(11) default NULL,
  `product_id` bigint(11) default NULL,
  `type` varchar(255) default NULL,
  `name` varchar(255) default NULL,
  `reference` varchar(255) default NULL,
  `description` text,
  `cancelled` tinyint(1) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `graphic_unit_measures` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `symbol` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `ibans` (
  `id` int(11) NOT NULL auto_increment,
  `has_iban_id` bigint(11) default NULL,
  `has_iban_type` varchar(255) default NULL,
  `account_name` varchar(255) default NULL,
  `bank_name` varchar(255) default NULL,
  `bank_code` varchar(255) default NULL,
  `branch_code` varchar(255) default NULL,
  `account_number` varchar(255) default NULL,
  `key` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `indicatives` (
  `id` int(11) NOT NULL auto_increment,
  `country_id` bigint(11) default NULL,
  `indicative` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `interventions` (
  `id` int(11) NOT NULL auto_increment,
  `delivery_note_id` bigint(11) default NULL,
  `on_site` tinyint(1) default NULL,
  `scheduled_delivery_at` datetime default NULL,
  `delivered` tinyint(1) default NULL,
  `comments` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `inventories` (
  `id` int(11) NOT NULL auto_increment,
  `closed` tinyint(1) default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `invoice_steps` (
  `id` int(11) NOT NULL auto_increment,
  `invoicing_step_id` bigint(11) default NULL,
  `status` varchar(255) default NULL,
  `started_at` datetime default NULL,
  `finished_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `invoicing_steps` (
  `id` int(11) NOT NULL auto_increment,
  `order_id` bigint(11) default NULL,
  `status` varchar(255) default NULL,
  `started_at` datetime default NULL,
  `finished_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `job_contract_types` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `limited` tinyint(1) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `job_contracts` (
  `id` int(11) NOT NULL auto_increment,
  `employee_id` bigint(11) default NULL,
  `employee_state_id` bigint(11) default NULL,
  `job_contract_type_id` bigint(11) default NULL,
  `start_date` date default NULL,
  `end_date` date default NULL,
  `departure` date default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `jobs` (
  `id` int(11) NOT NULL auto_increment,
  `service_id` bigint(11) default NULL,
  `name` varchar(255) default NULL,
  `responsible` tinyint(1) default NULL,
  `mission` text,
  `activity` text,
  `goal` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `leave_requests` (
  `id` int(11) NOT NULL auto_increment,
  `employee_id` bigint(11) default NULL,
  `leave_type_id` bigint(11) default NULL,
  `responsible_id` bigint(11) default NULL,
  `observer_id` bigint(11) default NULL,
  `director_id` bigint(11) default NULL,
  `cancelled_by` bigint(11) default NULL,
  `status` bigint(11) default NULL,
  `start_date` date default NULL,
  `end_date` date default NULL,
  `checked_at` datetime default NULL,
  `noticed_at` datetime default NULL,
  `ended_at` datetime default NULL,
  `cancelled_at` datetime default NULL,
  `start_half` tinyint(1) default NULL,
  `end_half` tinyint(1) default NULL,
  `responsible_agreement` tinyint(1) default NULL,
  `director_agreement` tinyint(1) default NULL,
  `comment` text,
  `responsible_remarks` text,
  `observer_remarks` text,
  `director_remarks` text,
  `acquired_leaves_days` float default NULL,
  `duration` float default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `leave_types` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `leaves` (
  `id` int(11) NOT NULL auto_increment,
  `employee_id` bigint(11) default NULL,
  `leave_type_id` bigint(11) default NULL,
  `leave_request_id` bigint(11) default NULL,
  `start_date` date default NULL,
  `end_date` date default NULL,
  `start_half` tinyint(1) default NULL,
  `end_half` tinyint(1) default NULL,
  `cancelled` tinyint(1) default NULL,
  `duration` float default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `legal_forms` (
  `id` int(11) NOT NULL auto_increment,
  `third_type_id` bigint(11) default NULL,
  `name` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `memorandums` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` bigint(11) default NULL,
  `title` varchar(255) default NULL,
  `subject` varchar(255) default NULL,
  `signature` varchar(255) default NULL,
  `text` text,
  `published_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `memorandums_services` (
  `id` int(11) NOT NULL auto_increment,
  `service_id` bigint(11) default NULL,
  `memorandum_id` bigint(11) default NULL,
  `recursive` tinyint(1) default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `menus` (
  `id` int(11) NOT NULL auto_increment,
  `parent_id` bigint(11) default NULL,
  `feature_id` bigint(11) default NULL,
  `name` varchar(255) default NULL,
  `title` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `separator` varchar(255) default NULL,
  `position` bigint(11) default NULL,
  `hidden` tinyint(1) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=87 DEFAULT CHARSET=utf8;

CREATE TABLE `mime_type_extensions` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `mime_type_id` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `mime_types` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `missing_elements` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `orders_steps_id` bigint(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `mockup_types` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `number_types` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `numbers` (
  `id` int(11) NOT NULL auto_increment,
  `has_number_id` bigint(11) default NULL,
  `has_number_type` varchar(255) default NULL,
  `indicative_id` bigint(11) default NULL,
  `number_type_id` bigint(11) default NULL,
  `number` varchar(255) default NULL,
  `visible` tinyint(1) default '1',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `order_form_types` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `order_logs` (
  `id` int(11) NOT NULL auto_increment,
  `order_id` bigint(11) default NULL,
  `user_id` bigint(11) default NULL,
  `controller` varchar(255) default NULL,
  `action` varchar(255) default NULL,
  `parameters` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `order_types` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `order_types_society_activity_sectors` (
  `society_activity_sector_id` bigint(11) default NULL,
  `order_type_id` bigint(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `orders` (
  `id` int(11) NOT NULL auto_increment,
  `commercial_id` bigint(11) default NULL,
  `user_id` bigint(11) default NULL,
  `customer_id` bigint(11) default NULL,
  `establishment_id` bigint(11) default NULL,
  `society_activity_sector_id` bigint(11) default NULL,
  `order_type_id` bigint(11) default NULL,
  `approaching_id` bigint(11) default NULL,
  `title` varchar(255) default NULL,
  `customer_needs` text,
  `closed_at` datetime default NULL,
  `previsional_delivery` date default NULL,
  `quotation_deadline` date default NULL,
  `delivery_time` bigint(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `participants` (
  `id` int(11) NOT NULL auto_increment,
  `event_id` bigint(11) default NULL,
  `employee_id` bigint(11) default NULL,
  `name` text,
  `email` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `payment_methods` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `payment_steps` (
  `id` int(11) NOT NULL auto_increment,
  `invoicing_step_id` bigint(11) default NULL,
  `status` varchar(255) default NULL,
  `started_at` datetime default NULL,
  `finished_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `payment_time_limits` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `permission_methods` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `title` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;

CREATE TABLE `permissions` (
  `id` int(11) NOT NULL auto_increment,
  `role_id` bigint(11) default NULL,
  `has_permissions_type` varchar(255) default NULL,
  `has_permissions_id` bigint(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `permissions_permission_methods` (
  `id` int(11) NOT NULL auto_increment,
  `permission_id` bigint(11) default NULL,
  `permission_method_id` bigint(11) default NULL,
  `active` tinyint(1) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `pre_invoicing_steps` (
  `id` int(11) NOT NULL auto_increment,
  `order_id` bigint(11) default NULL,
  `status` varchar(255) default NULL,
  `started_at` datetime default NULL,
  `finished_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `premia` (
  `id` int(11) NOT NULL auto_increment,
  `employee_id` bigint(11) default NULL,
  `date` date default NULL,
  `amount` decimal(65,30) default NULL,
  `remark` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `press_proof_items` (
  `id` int(11) NOT NULL auto_increment,
  `press_proof_id` bigint(11) default NULL,
  `graphic_item_version_id` bigint(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `press_proof_steps` (
  `id` int(11) NOT NULL auto_increment,
  `commercial_step_id` bigint(11) default NULL,
  `status` varchar(255) default NULL,
  `started_at` datetime default NULL,
  `finished_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `press_proofs` (
  `id` int(11) NOT NULL auto_increment,
  `order_id` bigint(11) default NULL,
  `product_id` bigint(11) default NULL,
  `creator_id` bigint(11) default NULL,
  `internal_actor_id` bigint(11) default NULL,
  `revoked_by_id` bigint(11) default NULL,
  `document_sending_method_id` bigint(11) default NULL,
  `signed_press_proof_file_size` bigint(11) default NULL,
  `status` varchar(255) default NULL,
  `reference` varchar(255) default NULL,
  `signed_press_proof_file_name` varchar(255) default NULL,
  `signed_press_proof_content_type` varchar(255) default NULL,
  `signed_press_proof_updated_at` datetime default NULL,
  `revoked_comment` text,
  `confirmed_on` date default NULL,
  `signed_on` date default NULL,
  `sended_on` date default NULL,
  `revoked_on` date default NULL,
  `cancelled_on` date default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `product_reference_categories` (
  `id` int(11) NOT NULL auto_increment,
  `product_reference_category_id` bigint(11) default NULL,
  `name` varchar(255) default NULL,
  `enable` tinyint(1) default '1',
  `product_references_count` bigint(11) default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `product_references` (
  `id` int(11) NOT NULL auto_increment,
  `product_reference_category_id` bigint(11) default NULL,
  `reference` varchar(255) default NULL,
  `name` varchar(255) default NULL,
  `description` text,
  `production_cost_manpower` float default NULL,
  `production_time` float default NULL,
  `delivery_cost_manpower` float default NULL,
  `delivery_time` float default NULL,
  `vat` float default NULL,
  `enable` tinyint(1) default '1',
  `products_count` bigint(11) default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_product_references_on_reference` (`reference`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `products` (
  `id` int(11) NOT NULL auto_increment,
  `product_reference_id` bigint(11) default NULL,
  `order_id` bigint(11) default NULL,
  `reference` varchar(255) default NULL,
  `name` varchar(255) default NULL,
  `description` text,
  `dimensions` varchar(255) default NULL,
  `unit_price` float default NULL,
  `quantity` float default NULL,
  `discount` float default NULL,
  `vat` float default NULL,
  `position` bigint(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_products_on_reference` (`reference`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `quote_items` (
  `id` int(11) NOT NULL auto_increment,
  `quote_id` bigint(11) default NULL,
  `product_id` bigint(11) default NULL,
  `name` varchar(255) default NULL,
  `description` text,
  `dimensions` varchar(255) default NULL,
  `unit_price` float default NULL,
  `quantity` float default NULL,
  `discount` float default NULL,
  `vat` float default NULL,
  `position` bigint(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `quotes` (
  `id` int(11) NOT NULL auto_increment,
  `order_id` bigint(11) default NULL,
  `creator_id` bigint(11) default NULL,
  `send_quote_method_id` bigint(11) default NULL,
  `order_form_type_id` bigint(11) default NULL,
  `status` varchar(255) default NULL,
  `public_number` varchar(255) default NULL,
  `carriage_costs` float default '0',
  `reduction` float default '0',
  `account` float default '0',
  `discount` float default '0',
  `sales_terms` text,
  `validity_delay_unit` varchar(255) default NULL,
  `validity_delay` bigint(11) default NULL,
  `order_form_file_name` varchar(255) default NULL,
  `order_form_content_type` varchar(255) default NULL,
  `order_form_file_size` bigint(11) default NULL,
  `confirmed_on` date default NULL,
  `cancelled_on` date default NULL,
  `sended_on` date default NULL,
  `signed_on` date default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_quotes_on_public_number` (`public_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `remarks` (
  `id` int(11) NOT NULL auto_increment,
  `has_remark_id` bigint(11) default NULL,
  `has_remark_type` varchar(255) default NULL,
  `user_id` bigint(11) default NULL,
  `text` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `roles` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `description` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `roles_users` (
  `role_id` bigint(11) default NULL,
  `user_id` bigint(11) default NULL,
  KEY `index_roles_users_on_role_id` (`role_id`),
  KEY `index_roles_users_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `salaries` (
  `id` int(11) NOT NULL auto_increment,
  `job_contract_id` bigint(11) default NULL,
  `gross_amount` float default NULL,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sales_processes` (
  `id` int(11) NOT NULL auto_increment,
  `order_type_id` bigint(11) default NULL,
  `step_id` bigint(11) default NULL,
  `activated` tinyint(1) default '1',
  `depending_previous` tinyint(1) default '0',
  `required` tinyint(1) default '1',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sales_processes_steps` (
  `id` int(11) NOT NULL auto_increment,
  `sales_process_id` bigint(11) default NULL,
  `step_id` bigint(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `schedules` (
  `id` int(11) NOT NULL auto_increment,
  `service_id` bigint(11) default NULL,
  `morning_start` float default NULL,
  `morning_end` float default NULL,
  `afternoon_start` float default NULL,
  `afternoon_end` float default NULL,
  `day` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `send_quote_methods` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `services` (
  `id` int(11) NOT NULL auto_increment,
  `service_parent_id` bigint(11) default NULL,
  `name` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sessions` (
  `id` int(11) NOT NULL auto_increment,
  `session_id` varchar(255) NOT NULL default '',
  `data` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `ship_to_addresses` (
  `id` int(11) NOT NULL auto_increment,
  `order_id` bigint(11) default NULL,
  `establishment_id` bigint(11) default NULL,
  `establishment_name` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `society_activity_sectors` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `activated` tinyint(1) default '1',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `step_dependencies` (
  `step_id` bigint(11) default NULL,
  `step_dependent` bigint(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `steps` (
  `id` int(11) NOT NULL auto_increment,
  `parent_id` bigint(11) default NULL,
  `name` varchar(255) default NULL,
  `title` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `position` bigint(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;

CREATE TABLE `subcontractor_requests` (
  `id` int(11) NOT NULL auto_increment,
  `subcontractor_id` bigint(11) default NULL,
  `survey_step_id` bigint(11) default NULL,
  `job_needed` text,
  `price` float default NULL,
  `attachment_file_name` varchar(255) default NULL,
  `attachment_content_type` varchar(255) default NULL,
  `attachment_file_size` bigint(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `survey_interventions` (
  `id` int(11) NOT NULL auto_increment,
  `survey_step_id` bigint(11) default NULL,
  `internal_actor_id` bigint(11) default NULL,
  `start_date` datetime default NULL,
  `duration_hours` bigint(11) default NULL,
  `duration_minutes` bigint(11) default NULL,
  `comment` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `survey_steps` (
  `id` int(11) NOT NULL auto_increment,
  `commercial_step_id` bigint(11) default NULL,
  `status` varchar(255) default NULL,
  `started_at` datetime default NULL,
  `finished_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `taggings` (
  `id` int(11) NOT NULL auto_increment,
  `tag_id` bigint(11) default NULL,
  `taggable_id` bigint(11) default NULL,
  `taggable_type` varchar(255) default NULL,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_taggings_on_tag_id` (`tag_id`),
  KEY `index_taggings_on_taggable_id_and_taggable_type` (`taggable_id`,`taggable_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tags` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `third_types` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `thirds` (
  `id` int(11) NOT NULL auto_increment,
  `legal_form_id` bigint(11) default NULL,
  `activity_sector_id` bigint(11) default NULL,
  `type` varchar(255) default NULL,
  `name` varchar(255) default NULL,
  `siret_number` varchar(255) default NULL,
  `activities` varchar(255) default NULL,
  `website` varchar(255) default NULL,
  `note` bigint(11) default '0',
  `activated` tinyint(1) default '1',
  `payment_method_id` bigint(11) default NULL,
  `payment_time_limit_id` bigint(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `unit_measures` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `symbol` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `username` varchar(255) default NULL,
  `password` varchar(255) default NULL,
  `enabled` tinyint(1) default NULL,
  `password_updated_at` datetime default NULL,
  `last_connection` datetime default NULL,
  `last_activity` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_users_on_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `vats` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `rate` float default NULL,
  `position` bigint(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('20080715111151');

INSERT INTO schema_migrations (version) VALUES ('20080718125001');

INSERT INTO schema_migrations (version) VALUES ('20080728080602');

INSERT INTO schema_migrations (version) VALUES ('20080728080636');

INSERT INTO schema_migrations (version) VALUES ('20080728083145');

INSERT INTO schema_migrations (version) VALUES ('20080729134155');

INSERT INTO schema_migrations (version) VALUES ('20080730041643');

INSERT INTO schema_migrations (version) VALUES ('20080730042545');

INSERT INTO schema_migrations (version) VALUES ('20080731072326');

INSERT INTO schema_migrations (version) VALUES ('20080731112556');

INSERT INTO schema_migrations (version) VALUES ('20080731165831');

INSERT INTO schema_migrations (version) VALUES ('20080731165849');

INSERT INTO schema_migrations (version) VALUES ('20080731165909');

INSERT INTO schema_migrations (version) VALUES ('20080801051728');

INSERT INTO schema_migrations (version) VALUES ('20080804064522');

INSERT INTO schema_migrations (version) VALUES ('20080804070616');

INSERT INTO schema_migrations (version) VALUES ('20080804072912');

INSERT INTO schema_migrations (version) VALUES ('20080804074250');

INSERT INTO schema_migrations (version) VALUES ('20080804080244');

INSERT INTO schema_migrations (version) VALUES ('20080804082018');

INSERT INTO schema_migrations (version) VALUES ('20080804082539');

INSERT INTO schema_migrations (version) VALUES ('20080805064745');

INSERT INTO schema_migrations (version) VALUES ('20080805065943');

INSERT INTO schema_migrations (version) VALUES ('20080805074520');

INSERT INTO schema_migrations (version) VALUES ('20080805082347');

INSERT INTO schema_migrations (version) VALUES ('20080805082411');

INSERT INTO schema_migrations (version) VALUES ('20080805082458');

INSERT INTO schema_migrations (version) VALUES ('20080805132617');

INSERT INTO schema_migrations (version) VALUES ('20080805132639');

INSERT INTO schema_migrations (version) VALUES ('20080806051710');

INSERT INTO schema_migrations (version) VALUES ('20080806054011');

INSERT INTO schema_migrations (version) VALUES ('20080806072721');

INSERT INTO schema_migrations (version) VALUES ('20080806100420');

INSERT INTO schema_migrations (version) VALUES ('20080806103212');

INSERT INTO schema_migrations (version) VALUES ('20080806103536');

INSERT INTO schema_migrations (version) VALUES ('20080807055950');

INSERT INTO schema_migrations (version) VALUES ('20080807060305');

INSERT INTO schema_migrations (version) VALUES ('20080807060328');

INSERT INTO schema_migrations (version) VALUES ('20080807060532');

INSERT INTO schema_migrations (version) VALUES ('20080808055748');

INSERT INTO schema_migrations (version) VALUES ('20080813074131');

INSERT INTO schema_migrations (version) VALUES ('20080814135019');

INSERT INTO schema_migrations (version) VALUES ('20080821062350');

INSERT INTO schema_migrations (version) VALUES ('20080821063020');

INSERT INTO schema_migrations (version) VALUES ('20080821104317');

INSERT INTO schema_migrations (version) VALUES ('20080822121050');

INSERT INTO schema_migrations (version) VALUES ('20080822121447');

INSERT INTO schema_migrations (version) VALUES ('20080822125617');

INSERT INTO schema_migrations (version) VALUES ('20080822131125');

INSERT INTO schema_migrations (version) VALUES ('20080822131214');

INSERT INTO schema_migrations (version) VALUES ('20080822131329');

INSERT INTO schema_migrations (version) VALUES ('20080822131742');

INSERT INTO schema_migrations (version) VALUES ('20080822131903');

INSERT INTO schema_migrations (version) VALUES ('20080825070549');

INSERT INTO schema_migrations (version) VALUES ('20080829075113');

INSERT INTO schema_migrations (version) VALUES ('20080829122410');

INSERT INTO schema_migrations (version) VALUES ('20080829123032');

INSERT INTO schema_migrations (version) VALUES ('20080902070037');

INSERT INTO schema_migrations (version) VALUES ('20080903053112');

INSERT INTO schema_migrations (version) VALUES ('20080904195927');

INSERT INTO schema_migrations (version) VALUES ('20080915051832');

INSERT INTO schema_migrations (version) VALUES ('20080915065602');

INSERT INTO schema_migrations (version) VALUES ('20080917101629');

INSERT INTO schema_migrations (version) VALUES ('20080917101722');

INSERT INTO schema_migrations (version) VALUES ('20080917101821');

INSERT INTO schema_migrations (version) VALUES ('20080917102122');

INSERT INTO schema_migrations (version) VALUES ('20080917103126');

INSERT INTO schema_migrations (version) VALUES ('20080917104113');

INSERT INTO schema_migrations (version) VALUES ('20080917110455');

INSERT INTO schema_migrations (version) VALUES ('20080917111142');

INSERT INTO schema_migrations (version) VALUES ('20080917111600');

INSERT INTO schema_migrations (version) VALUES ('20080917113542');

INSERT INTO schema_migrations (version) VALUES ('20080917114206');

INSERT INTO schema_migrations (version) VALUES ('20080917123046');

INSERT INTO schema_migrations (version) VALUES ('20080923071718');

INSERT INTO schema_migrations (version) VALUES ('20080923122135');

INSERT INTO schema_migrations (version) VALUES ('20080924053818');

INSERT INTO schema_migrations (version) VALUES ('20080924053820');

INSERT INTO schema_migrations (version) VALUES ('20080929131810');

INSERT INTO schema_migrations (version) VALUES ('20081002051511');

INSERT INTO schema_migrations (version) VALUES ('20081002072047');

INSERT INTO schema_migrations (version) VALUES ('20081002114929');

INSERT INTO schema_migrations (version) VALUES ('20090227103136');

INSERT INTO schema_migrations (version) VALUES ('20090227105300');

INSERT INTO schema_migrations (version) VALUES ('20090306071234');

INSERT INTO schema_migrations (version) VALUES ('20090519055044');

INSERT INTO schema_migrations (version) VALUES ('20090608114343');

INSERT INTO schema_migrations (version) VALUES ('20090610105108');

INSERT INTO schema_migrations (version) VALUES ('20090611075935');

INSERT INTO schema_migrations (version) VALUES ('20090612061403');

INSERT INTO schema_migrations (version) VALUES ('20090716111902');

INSERT INTO schema_migrations (version) VALUES ('20090716111948');

INSERT INTO schema_migrations (version) VALUES ('20090716112012');

INSERT INTO schema_migrations (version) VALUES ('20090716114517');

INSERT INTO schema_migrations (version) VALUES ('20090721063545');

INSERT INTO schema_migrations (version) VALUES ('20090721064124');

INSERT INTO schema_migrations (version) VALUES ('20090724054840');

INSERT INTO schema_migrations (version) VALUES ('20090731131619');

INSERT INTO schema_migrations (version) VALUES ('20090929075521');

INSERT INTO schema_migrations (version) VALUES ('20090929080549');

INSERT INTO schema_migrations (version) VALUES ('20090930082259');

INSERT INTO schema_migrations (version) VALUES ('20091007110542');

INSERT INTO schema_migrations (version) VALUES ('20091014122416');

INSERT INTO schema_migrations (version) VALUES ('20091014122459');

INSERT INTO schema_migrations (version) VALUES ('20091014123705');

INSERT INTO schema_migrations (version) VALUES ('20091026081226');

INSERT INTO schema_migrations (version) VALUES ('20091103124150');

INSERT INTO schema_migrations (version) VALUES ('20091112122118');

INSERT INTO schema_migrations (version) VALUES ('20091127101405');

INSERT INTO schema_migrations (version) VALUES ('20091127104900');

INSERT INTO schema_migrations (version) VALUES ('20091127104915');

INSERT INTO schema_migrations (version) VALUES ('20091127105005');

INSERT INTO schema_migrations (version) VALUES ('20091127105023');

INSERT INTO schema_migrations (version) VALUES ('20091127105044');

INSERT INTO schema_migrations (version) VALUES ('20091211050133');

INSERT INTO schema_migrations (version) VALUES ('20091217123123');

INSERT INTO schema_migrations (version) VALUES ('20100115061137');

INSERT INTO schema_migrations (version) VALUES ('20100121095806');

INSERT INTO schema_migrations (version) VALUES ('20100121100208');