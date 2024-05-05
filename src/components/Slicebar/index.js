import clsx from 'clsx';
import style from './Slicebar.module.scss';
import { NavLink } from 'react-router-dom';

function Slicebar() {
    return (
        <div className={clsx("d-flex flex-column flex-shrink-0 p-3 bg-light", style.SlicebarArea)}>
            <span className="fs-4">Sidebar</span>
            <hr />
            <ul className="nav nav-pills flex-column mb-auto">
                <li>
                    <NavLink to="/dashboard" className="nav-link link-dark" activeClassName="activeLink">Dashboard</NavLink>
                </li>
                <li>
                    <NavLink to="/products" className="nav-link link-dark" activeClassName="activeLink">Products</NavLink>
                </li>
                <li>
                    <NavLink to="/orders" className="nav-link link-dark" activeClassName="activeLink">Orders</NavLink>
                </li>
                <li>
                    <NavLink to="/staffs" className="nav-link link-dark" activeClassName="activeLink">Staffs</NavLink>
                </li>
                <li>
                    <NavLink to="/customers" className="nav-link link-dark" activeClassName="activeLink">Customers</NavLink>
                </li>
                <li>
                    <NavLink to="/stockroom" className="nav-link link-dark" activeClassName="activeLink">Stockroom</NavLink>
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