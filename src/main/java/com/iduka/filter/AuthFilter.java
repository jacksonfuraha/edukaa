package com.iduka.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.*;

@WebFilter(urlPatterns = {"/buyer/*", "/seller/*", "/chat/*", "/profile"})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest  req = (HttpServletRequest)  request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        boolean loggedIn = (session != null && session.getAttribute("user") != null);
        if (!loggedIn) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String uri  = req.getRequestURI();
        String role = (String) session.getAttribute("userRole");

        if (uri.contains("/buyer/") && !"BUYER".equals(role)) {
            res.sendRedirect(req.getContextPath() + "/home");
        } else if (uri.contains("/seller/") && !"SELLER".equals(role)) {
            res.sendRedirect(req.getContextPath() + "/home");
        } else if (uri.contains("/seller/")) {
            // Check if seller is verified — block unverified sellers
            com.iduka.model.User user =
                (com.iduka.model.User) session.getAttribute("user");
            if (user != null && !user.isVerified()) {
                res.sendRedirect(req.getContextPath() +
                    "/login?error=Your+seller+account+is+pending+verification.+" +
                    "Our+team+will+review+your+documents+within+24+hours.+" +
                    "You+will+receive+an+email+once+approved.");
            } else {
                chain.doFilter(request, response);
            }
        } else {
            chain.doFilter(request, response);
        }
    }
}
