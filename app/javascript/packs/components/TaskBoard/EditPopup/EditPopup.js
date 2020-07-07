import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { isNil } from 'ramda';

import useStyles from './useStyles';

import Modal from '@material-ui/core/Modal';
import Card from '@material-ui/core/Card';
import CardHeader from '@material-ui/core/CardHeader';
import IconButton from '@material-ui/core/IconButton';
import CardContent from '@material-ui/core/CardContent';
import CircularProgress from '@material-ui/core/CircularProgress';
import CardActions from '@material-ui/core/CardActions';
import Button from '@material-ui/core/Button';
import CloseIcon from '@material-ui/icons/Close';

import TaskPresenter from 'presenters/TaskPresenter';
import Form from 'packs/components/TaskBoard/Form';
import ImageUpload from './ImageUpload';

const EditPopup = ({ cardId, onClose, onCardDestroy, onLoadCard, onCardUpdate, onAttachImage, onRemoveImage }) => {
  const [task, setTask] = useState(null);
  const [isSaving, setSaving] = useState(false);
  const [errors, setErrors] = useState({});
  const styles = useStyles();

  useEffect(() => {
    onLoadCard(cardId).then(setTask);
  }, []);

  const handleAttachImage = (image) => {
    onAttachImage(task, image).then(() => {
      onLoadCard(cardId).then(setTask);
    });
  };

  const handleRemoveImage = () => {
    onRemoveImage(task).then(() => {
      onLoadCard(cardId).then(setTask);
    });
  };

  const handleCardUpdate = () => {
    setSaving(true);

    onCardUpdate(task).catch((error) => {
      setSaving(false);
      setErrors(error || {});

      if (error instanceof Error) {
        alert(`Update Failed! Error: ${error.message}`);
      }
    });
  };

  const handleCardDestroy = () => {
    setSaving(true);

    onCardDestroy(task).catch((error) => {
      setSaving(false);

      alert(`Destrucion Failed! Error: ${error.message}`);
    });
  };
  const isLoading = isNil(task);

  return (
    <Modal className={styles.modal} open onClose={onClose}>
      <Card className={styles.root}>
        <CardHeader
          action={
            <IconButton onClick={onClose}>
              <CloseIcon />
            </IconButton>
          }
          title={
            isLoading
              ? 'Your task is loading. Please be patient.'
              : `Task # ${TaskPresenter.id(task)} [${TaskPresenter.name(task)}]`
          }
        />
        <CardContent>
          {isLoading ? (
            <div className={styles.loader}>
              <CircularProgress />
            </div>
          ) : (
            <Form errors={errors} onChange={setTask} task={task} />
          )}

          {isNil(TaskPresenter.imageUrl(task)) ? (
            <div className={styles.imageUploadContainer}>
              <ImageUpload onUpload={handleAttachImage} />
            </div>
          ) : (
            <div className={styles.previewContainer}>
              <a href={TaskPresenter.imageUrl(task)}>
                <img className={styles.preview} src={TaskPresenter.imageUrl(task)} alt="Attachment" />
              </a>
              <Button variant="contained" size="small" color="primary" onClick={handleRemoveImage}>
                Remove image
              </Button>
            </div>
          )}
        </CardContent>
        <CardActions className={styles.actions}>
          <Button
            disabled={isLoading || isSaving}
            onClick={handleCardUpdate}
            size="small"
            variant="contained"
            color="secondary"
          >
            Update
          </Button>
          <Button
            disabled={isLoading || isSaving}
            onClick={handleCardDestroy}
            size="small"
            variant="contained"
            color="secondary"
          >
            Destroy
          </Button>
        </CardActions>
      </Card>
    </Modal>
  );
};

EditPopup.propTypes = {
  onRemoveImage: PropTypes.func.isRequired,
  onAttachImage: PropTypes.func.isRequired,
  onLoadCard: PropTypes.func.isRequired,
  onCardDestroy: PropTypes.func.isRequired,
  onCardUpdate: PropTypes.func.isRequired,
  onClose: PropTypes.func.isRequired,
  cardId: PropTypes.number.isRequired,
};

export default EditPopup;
