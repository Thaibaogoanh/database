import Login from '~/pages/Login';
import Dashboard from '~/pages/Dashboard';
import Products from '~/pages/Product';
import Orders from '~/pages/Order';
import Staffs from '~/pages/Staffs';
import Customers from '~/pages/Customer';

const publicRoutes = [
    {
        path: '/',
        component: Login,
        layout: null,
    },
    {
        path: '/dashboard',
        component: Dashboard,
    },
    {
        path: '/staffs',
        component: Staffs,
    },
    {
        path: '/products',
        component: Products,
    },
    {
        path: '/orders',
        component: Orders,
    },
    {
        path: '/customers',
        component: Customers,
    },
];

const privateRoutes = [];

export { publicRoutes, privateRoutes };
