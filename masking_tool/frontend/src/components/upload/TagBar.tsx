import {Autocomplete, Box, FilterOptionsState, TextField, createFilterOptions} from '@mui/material';
import React from 'react';
import FileTag from './FileTag';

const filter = createFilterOptions<string>();

interface TagBarProps {
    tags: string[];
    onChange: (tags: string[]) => void;
}

const TagBar = (props: TagBarProps) => {
    const allKnownTags = ['Test 1', 'Test 2'];

    return (
        <Box component="div">
            <Autocomplete
                size={'small'}
                multiple={true}
                options={allKnownTags}
                value={props.tags}
                selectOnFocus={true}
                clearOnBlur={true}
                handleHomeEndKeys={true}
                filterSelectedOptions={true}
                onChange={(_, newTags: string[]) => props.onChange(newTags)}
                disableClearable={true}
                filterOptions={(options, params: FilterOptionsState<string>) => {
                    const filteredOptions = filter(options, params);

                    if (
                        params.inputValue !== '' &&
                        !filteredOptions.includes(params.inputValue) &&
                        !props.tags.includes(params.inputValue)
                    ) {
                        filteredOptions.push(params.inputValue);
                    }

                    return filteredOptions;
                }}
                renderInput={params => (
                    <TextField
                        {...params}
                        placeholder={'Add more ...'}
                        variant={'outlined'}
                        label={'Tags'}
                        inputProps={{
                            ...params.inputProps,
                            maxLength: 25,
                        }}
                    />
                )}
                renderTags={(value, getTagProps) => value.map((option, index) => (
                    <FileTag
                        label={option}
                        {...getTagProps({ index })}
                    />
                ))}
            />
        </Box>
    );
};

export default TagBar;
