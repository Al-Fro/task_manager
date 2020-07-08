import React, { useEffect, useState } from 'react';
import KanbanBoard from '@lourenci/react-kanban';
import { pick, propOr } from 'ramda';

import TaskForm from 'forms/TaskForm';
import TasksRepository from 'repositories/TasksRepository';
import TaskPresenter from 'presenters/TaskPresenter';
import { decamelize } from 'utils/keysConverter';

import ColumnHeader from './ColumnHeader';
import AddPopup from './AddPopup';
import AddButton from './AddButton';
import EditPopup from './EditPopup';
import Task from './Task';

const STATES = [
  { key: 'new_task', value: 'New' },
  { key: 'in_development', value: 'In Dev' },
  { key: 'in_qa', value: 'In QA' },
  { key: 'in_code_review', value: 'in CR' },
  { key: 'ready_for_release', value: 'Ready for release' },
  { key: 'released', value: 'Released' },
  { key: 'archived', value: 'Archived' },
];

const initialBoard = {
  columns: STATES.map((column) => ({
    id: column.key,
    title: column.value,
    cards: [],
    meta: {},
  })),
};

const MODES = {
  ADD: 'add',
  NONE: 'none',
  EDIT: 'edit',
};

const TaskBoard = () => {
  const [board, setBoard] = useState(initialBoard);

  const [boardCards, setBoardCards] = useState({});

  const [isUpdating, setUpdating] = useState(false);

  const [openedTaskId, setOpenedTaskId] = useState(null);

  const [mode, setMode] = useState(MODES.NONE);

  const loadColumn = (state, page, perPage) => {
    return TasksRepository.index({
      q: { stateEq: state },
      page,
      perPage,
    });
  };

  const loadColumnInitial = (state, page = 1, perPage = 10) => {
    loadColumn(state, page, perPage).then(({ data }) => {
      setBoardCards((prevState) => {
        return {
          ...prevState,
          [state]: { cards: data.items, meta: data.meta },
        };
      });
    });
  };

  const loadColumnMore = (state, page = 1, perPage = 10) => {
    loadColumn(state, page, perPage).then(({ data }) => {
      setBoardCards((prevState) => {
        return {
          ...prevState,
          [state]: { cards: [...prevState[state].cards, ...data.items], meta: data.meta },
        };
      });
    });
  };

  const generateBoard = () => {
    const newBoard = {
      columns: STATES.map(({ key, value }) => {
        return {
          id: key,
          title: value,
          cards: propOr([], 'cards', boardCards[key]),
          meta: propOr({}, 'meta', boardCards[key]),
        };
      }),
    };
    setBoard(newBoard);
  };

  const loadBoard = () => {
    STATES.map(({ key }) => loadColumnInitial(key));
  };

  useEffect(() => loadBoard(), []);
  useEffect(() => generateBoard(), [boardCards]);

  const handleCardDragEnd = (task, source, destination) => {
    const transition = TaskPresenter.transitions(task).find(({ to }) => destination.toColumnId === to);
    if (!transition) {
      return null;
    }
    setUpdating(true);

    return TasksRepository.update(TaskPresenter.id(task), { task: { stateEvent: transition.event } })
      .then(() => {
        loadColumnInitial(destination.toColumnId);
        loadColumnInitial(source.fromColumnId);
        setUpdating(false);
      })
      .catch((error) => {
        alert(`Move failed! ${error.message}`);
        setUpdating(false);
      });
  };

  const handleOpenAddPopup = () => {
    setMode(MODES.ADD);
  };

  const handleOpenEditPopup = (task) => {
    setOpenedTaskId(TaskPresenter.id(task));
    setMode(MODES.EDIT);
  };

  const handleClose = () => {
    setMode(MODES.NONE);
    setOpenedTaskId(null);
  };

  const handleTaskCreate = (params) => {
    const attributes = TaskForm.attributesToSubmit(params);

    return TasksRepository.create(attributes).then(({ data: { task } }) => {
      loadColumnInitial(TaskPresenter.state(task));
      handleClose();
    });
  };

  const loadTask = (id) => {
    return TasksRepository.show(id).then(({ data: { task } }) => task);
  };

  const handleTaskUpdate = (task) => {
    const attributes = TaskForm.attributesToSubmit(task);

    return TasksRepository.update(task.id, attributes).then(() => {
      loadColumnInitial(TaskPresenter.state(task));
      handleClose();
    });
  };

  const handleTaskDestroy = (task) => {
    return TasksRepository.destroy(task.id).then(() => {
      loadColumnInitial(TaskPresenter.state(task));
      handleClose();
    });
  };

  const handleAttachImage = (task, image) => {
    const pertmittedKeys = ['cropX', 'cropY', 'cropWidth', 'cropHeight'];

    const body = {
      attachment: {
        ...decamelize(pick(pertmittedKeys, image.attachment)),
        image: image.attachment.image,
      },
    };

    return TasksRepository.putFormData(task.id, body);
  };

  const handleRemoveImage = (task) => {
    return TasksRepository.removeImage(task.id);
  };

  return (
    <>
      <KanbanBoard
        disableCardDrag={isUpdating}
        onCardDragEnd={handleCardDragEnd}
        renderCard={(card) => <Task onClick={handleOpenEditPopup} task={card} />}
        renderColumnHeader={(column) => <ColumnHeader column={column} onLoadMore={loadColumnMore} />}
      >
        {board}
      </KanbanBoard>
      <AddButton onClick={handleOpenAddPopup} />
      {mode === MODES.ADD && <AddPopup onCreateCard={handleTaskCreate} onClose={handleClose} />}
      {mode === MODES.EDIT && (
        <EditPopup
          onLoadCard={loadTask}
          onCardDestroy={handleTaskDestroy}
          onCardUpdate={handleTaskUpdate}
          onClose={handleClose}
          cardId={openedTaskId}
          onAttachImage={handleAttachImage}
          onRemoveImage={handleRemoveImage}
        />
      )}
    </>
  );
};

export default TaskBoard;
