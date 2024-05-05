import clsx from 'clsx';
import style from './Slicebar.module.scss';
import { NavLink } from 'react-router-dom';
import CoffeeIcon from '@mui/icons-material/Coffee';

function Slicebar() {
    return (
        <div className={clsx("d-flex flex-column flex-shrink-0 p-3 bg-light", style.SlicebarArea)}>
            <h3><CoffeeIcon/> Quán Ế</h3>
            <hr />
            <ul className="nav nav-pills flex-column mb-auto">
                <li>
                    <NavLink to="/dashboard" className={({ isActive }) => isActive ? clsx("nav-link link-dark", style.active) : "nav-link link-dark"}>Dashboard</NavLink>
                </li>
                <li>
                    <NavLink to="/products" className={({ isActive }) => isActive ? clsx("nav-link link-dark", style.active) : "nav-link link-dark"}>Products</NavLink>
                </li>
                <li>
                    <NavLink to="/orders" className={({ isActive }) => isActive ? clsx("nav-link link-dark", style.active) : "nav-link link-dark"}>Orders</NavLink>
                </li>
                <li>
                    <NavLink to="/staffs" className={({ isActive }) => isActive ? clsx("nav-link link-dark", style.active) : "nav-link link-dark"}>Staffs</NavLink>
                </li>
                <li>
                    <NavLink to="/customers" className={({ isActive }) => isActive ? clsx("nav-link link-dark", style.active) : "nav-link link-dark"}>Customers</NavLink>
                </li>
                <li>
                    <NavLink to="/stockroom" className={({ isActive }) => isActive ? clsx("nav-link link-dark", style.active) : "nav-link link-dark"}>Stockroom</NavLink>
                </li>
            </ul>
            <hr />
            <div className="dropdown">
                <a href="#" className="d-flex align-items-center link-dark text-decoration-none dropdown-toggle" id="dropdownUser2" data-bs-toggle="dropdown" aria-expanded="false">
                    <strong>Admin</strong>
                </a>
                <ul className="dropdown-menu text-small shadow" aria-labelledby="dropdownUser2">
                    <li><a className="dropdown-item" href="#">Sign out</a></li>
                </ul>
            </div>
        </div>
    );
}

export default Slicebar;