
const formatNumber = (value: number, options?: Intl.NumberFormatOptions): string =>
    value.toLocaleString('en-US', options);

const sizeUnitList: Array<{ value: number, unit: string }> = [
    { value: 1_000_000_000_000, unit: 'TB' },
    { value: 1_000_000_000, unit: 'GB' },
    { value: 1_000_000, unit: 'MB' },
    { value: 1_000, unit: 'KB' },
];

export const formatFileSize = (bytes: number): string => {
    for (const sizeUnit of sizeUnitList) {
        if (bytes >= sizeUnit.value) {
            const formattedNumber = formatNumber(
                bytes / sizeUnit.value,
                { minimumFractionDigits: 1, maximumFractionDigits: 2 },
            );

            return `${formattedNumber} ${sizeUnit.unit}`;
        }
    }

    return bytes.toFixed(2) + ' B';
};
