require('@rails/ujs').start();
require('@rails/activestorage').start();
require('channels');

import 'material-design-lite/material.js';
import WebpackerReact from 'webpacker-react';
import TaskBoard from './components/TaskBoard';
import 'stylesheets/application';

WebpackerReact.setup({ TaskBoard });
