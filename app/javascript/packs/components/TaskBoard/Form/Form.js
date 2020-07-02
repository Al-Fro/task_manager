import React from 'react';
import PropTypes from 'prop-types';
import { has } from 'ramda';

import TextField from '@material-ui/core/TextField';
import Button from '@material-ui/core/Button';

import useStyles from './useStyles';
import UserSelect from './UserSelect';
import TaskPresenter from 'presenters/TaskPresenter';
import ImageUpload from 'packs/components/TaskBoard/ImageUpload';

const Form = ({ errors, onChange, task }) => {
  const handleChangeTextField = (fieldName) => (event) => onChange({ ...task, [fieldName]: event.target.value });
  const styles = useStyles();

  const handleChangeSelect = (fieldName) => (user) => onChange({ ...task, [fieldName]: user });

  return (
    <form className={styles.root}>
      <TextField
        error={has('name', errors)}
        helperText={errors.name}
        onChange={handleChangeTextField('name')}
        value={TaskPresenter.name(task)}
        label="Name"
        required
        margin="dense"
      />
      <TextField
        error={has('description', errors)}
        helperText={errors.description}
        onChange={handleChangeTextField('description')}
        value={TaskPresenter.description(task)}
        label="Description"
        required
        multiline
        margin="dense"
      />
      <UserSelect
        label="Assignee"
        value={TaskPresenter.assignee(task)}
        onChange={handleChangeSelect('assignee')}
        isRequired
        isClearable
        error={has('assignee', errors)}
        helperText={errors.assignee}
      />
      {/* {isNil(TaskPresenter.imageUrl(task)) ? (
        <div className={styles.imageUploadContainer}>
          <ImageUpload onUpload={onAttachImage} />
        </div>
      ) : (
        <div className={styles.previewContainer}>
          <img className={styles.preview} src={imageUrl} alt="Attachment" />
          <Button variant="contained" size="small" color="primary" onClick={onRemoveImage}>
            Remove image
          </Button>
        </div>
      )} */}
    </form>
  );
};

Form.propTypes = {
  onChange: PropTypes.func.isRequired,
  task: TaskPresenter.shape().isRequired,
  errors: PropTypes.shape({
    name: PropTypes.arrayOf(PropTypes.string),
    description: PropTypes.arrayOf(PropTypes.string),
    author: PropTypes.arrayOf(PropTypes.string),
    assignee: PropTypes.arrayOf(PropTypes.string),
  }),
};

Form.defaultProps = {
  errors: {},
};

export default Form;
