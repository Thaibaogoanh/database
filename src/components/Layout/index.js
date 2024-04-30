import style from './Layout.module.scss';
import Slicebar from '../Slicebar';
import clsx from 'clsx';

function Layout({ children }) {
    return (
        <div className={clsx(style.Layout)}>
            <Slicebar />
            <main>{children}</main>
        </div>
    );
}

export default Layout;
