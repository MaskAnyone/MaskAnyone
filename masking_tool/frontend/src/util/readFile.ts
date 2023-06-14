export const readFile = (file: File): Promise<string> => {
    return new Promise<string>((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => resolve(reader.result as string);
        reader.onerror = () => reject();
        reader.readAsText(file, 'UTF-8');
    });
};

export const readFileArrayBuffer = (file: File): Promise<ArrayBuffer> => {
    return new Promise<ArrayBuffer>((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => resolve(reader.result as ArrayBuffer);
        reader.onerror = () => reject();
        reader.readAsArrayBuffer(file);
    });
};

export const readFileBase64 = (file: File): Promise<string> => {
    return new Promise<string>((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => resolve(reader.result as string);
        reader.onerror = () => reject();
        reader.readAsDataURL(file);
    });
};

export const readFileChunked = (
    file: File,
    callback: (chunk: ArrayBuffer) => Promise<void>,
    chunkSize: number,
): Promise<void> => {
    return new Promise<void>((resolve, reject) => {
        const reader = new FileReader();
        let currentStart = 0;

        reader.onerror = () => reject(reader.error);

        reader.onload = async () => {
            await callback(reader.result as ArrayBuffer);
            currentStart += chunkSize;

            if (currentStart < file.size) {
                reader.readAsArrayBuffer(file.slice(currentStart, currentStart + chunkSize));
            } else {
                resolve();
            }
        };

        reader.readAsArrayBuffer(file.slice(currentStart, currentStart + chunkSize));
    });
};
