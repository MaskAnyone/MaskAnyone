import React from 'react';
import {Button, ButtonProps, CircularProgress} from '@mui/material';

const styles = {
    loader: {
        position: 'absolute',
    },
};

interface LoaderButtonProps extends ButtonProps {
    loading?: boolean;
}

const LoaderButton = (props: LoaderButtonProps) => {
    const { loading, children, ...buttonProps } = props;

    return (
        <Button {...buttonProps} disabled={props.disabled || loading}>
            {children}
            {loading && <CircularProgress size={24} sx={styles.loader} color={'secondary'} />}
        </Button>
    );
};

export default LoaderButton;
