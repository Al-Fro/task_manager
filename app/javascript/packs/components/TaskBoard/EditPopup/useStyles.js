import { makeStyles } from '@material-ui/core/styles';

const useStyles = makeStyles(() => ({
  modal: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    outline: 0,
  },

  root: {
    width: 465,
  },

  loader: {
    display: 'flex',
    justifyContent: 'center',
  },

  actions: {
    display: 'flex',
    justifyContent: 'flex-end',
  },

  preview: {
    width: '100%',
    display: 'block',
    margin: [[10, 'auto']],
  },
}));

export default useStyles;
