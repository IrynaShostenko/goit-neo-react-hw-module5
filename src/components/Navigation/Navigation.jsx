import { NavLink } from "react-router-dom";
import css from "./Navigation.module.css";

const active = ({ isActive }) => (isActive ? css.active : "");

function Navigation() {
  return (
    <header className={css.header}>
      <nav className={css.nav}>
        <NavLink className={active} to="/">Home</NavLink>
        <NavLink className={active} to="/movies">Movies</NavLink>
      </nav>
    </header>
  );
}

export default Navigation;