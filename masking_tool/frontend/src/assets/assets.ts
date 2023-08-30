import logoWhite from './logos/logo_white.svg';
import logoBlack from './logos/logo_black.svg';
import shield, { ReactComponent as ShieldComponent } from './logos/shield.svg';
import file from './previews/file.png';
import uploadIllustration from './illustrations/upload.svg';

const Assets = {
    illustrations: {
        upload: uploadIllustration,
    },
    logos: {
        logoWhite,
        logoBlack,
        shield,
        ShieldComponent,
    },
    previews: {
        file,
    },
};

export default Assets;
