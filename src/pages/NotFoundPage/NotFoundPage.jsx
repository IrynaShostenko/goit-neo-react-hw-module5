import { Link } from "react-router-dom";
import css from "./NotFoundPage.module.css";

function NotFoundPage() {
  return (
    <main className={css.main}>
      <h1>404 — Page not found</h1>
      <p><Link to="/">Go to Home</Link></p>
    </main>
  );
}

export default NotFoundPage;