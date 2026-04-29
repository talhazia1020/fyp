import UserDashboardLayout from "examples/LayoutContainers/UserDashboardLayout";
import DashboardNavbar from "examples/Navbars/DashboardNavbar";
import MDBox from "components/MDBox";
import MDTypography from "components/MDTypography";
import Grid from "@mui/material/Grid";
import Card from "@mui/material/Card";
import MDButton from "components/MDButton";
import { useContext, useEffect, useState } from "react";
import { AuthContext } from "context/AuthContext";
import { getAuth } from "firebase/auth";
import * as apiService from "../api-service";
import { useNavigate } from "react-router-dom";
import LocalShippingIcon from "@mui/icons-material/LocalShipping";
import CheckCircleIcon from "@mui/icons-material/CheckCircle";
import PendingIcon from "@mui/icons-material/Pending";
import AssignmentIcon from "@mui/icons-material/Assignment";

function UserDashboard() {
  const { currentUser } = useContext(AuthContext);
  const [stats, setStats] = useState({
    pending: 0,
    assigned: 0,
    completed: 0,
    total: 0,
  });
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();
  const auth = getAuth();

  useEffect(() => {
    const fetchStats = async () => {
      try {
        if (auth.currentUser) {
          const idToken = await auth.currentUser.getIdToken();
          const requests = await apiService.getUserRequests({ userIdToken: idToken });
          
          const pending = requests.filter(r => r.status === "Pending").length;
          const assigned = requests.filter(r => r.status === "Assigned").length;
          const completed = requests.filter(r => r.status === "Completed").length;
          
          setStats({
            pending,
            assigned,
            completed,
            total: requests.length,
          });
        }
      } catch (error) {
        console.error("Error fetching stats:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchStats();
  }, [auth]);

  const StatCard = ({ title, count, icon, color, onClick }) => (
    <Card
      sx={{
        height: "100%",
        cursor: onClick ? "pointer" : "default",
        transition: "transform 0.2s",
        "&:hover": onClick ? { transform: "translateY(-4px)" } : {},
      }}
      onClick={onClick}
    >
      <MDBox p={3} display="flex" alignItems="center" justifyContent="space-between">
        <MDBox>
          <MDTypography variant="h6" color="text" fontWeight="medium">
            {title}
          </MDTypography>
          <MDTypography variant="h3" fontWeight="bold" color={color}>
            {loading ? "..." : count}
          </MDTypography>
        </MDBox>
        <MDBox
          sx={{
            p: 1.5,
            borderRadius: "50%",
            bgcolor: `${color}15`,
            color: color,
          }}
        >
          {icon}
        </MDBox>
      </MDBox>
    </Card>
  );

  return (
    <UserDashboardLayout>
      <DashboardNavbar />
      <MDBox py={3}>
        <MDBox mb={4}>
          <MDTypography variant="h4" fontWeight="bold" gutterBottom>
            Welcome{currentUser?.displayName ? `, ${currentUser.displayName}` : ""}!
          </MDTypography>
          <MDTypography variant="body1" color="text">
            Manage your recycling pickup requests from here.
          </MDTypography>
        </MDBox>

        <Grid container spacing={3} mb={4}>
          <Grid item xs={12} sm={6} md={3}>
            <StatCard
              title="Pending Requests"
              count={stats.pending}
              icon={<PendingIcon fontSize="large" />}
              color="warning"
              onClick={() => navigate("/user/requests")}
            />
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <StatCard
              title="Assigned"
              count={stats.assigned}
              icon={<AssignmentIcon fontSize="large" />}
              color="info"
              onClick={() => navigate("/user/requests")}
            />
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <StatCard
              title="Completed"
              count={stats.completed}
              icon={<CheckCircleIcon fontSize="large" />}
              color="success"
              onClick={() => navigate("/user/requests")}
            />
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <StatCard
              title="Total Requests"
              count={stats.total}
              icon={<LocalShippingIcon fontSize="large" />}
              color="primary"
              onClick={() => navigate("/user/requests")}
            />
          </Grid>
        </Grid>

        <Grid container spacing={3}>
          <Grid item xs={12} md={6}>
            <Card>
              <MDBox
                mx={2}
                mt={-3}
                py={3}
                px={2}
                variant="gradient"
                bgColor="info"
                borderRadius="lg"
                coloredShadow="info"
              >
                <MDTypography variant="h6" color="white" fontWeight="medium">
                  Quick Actions
                </MDTypography>
              </MDBox>
              <MDBox p={3}>
                <MDBox mb={2}>
                  <MDButton
                    variant="gradient"
                    color="info"
                    fullWidth
                    size="large"
                    onClick={() => navigate("/user/create-request")}
                    sx={{ py: 2 }}
                  >
                    Create New Pickup Request
                  </MDButton>
                </MDBox>
                <MDBox>
                  <MDButton
                    variant="outlined"
                    color="info"
                    fullWidth
                    size="large"
                    onClick={() => navigate("/user/requests")}
                    sx={{ py: 2 }}
                  >
                    View My Requests
                  </MDButton>
                </MDBox>
              </MDBox>
            </Card>
          </Grid>

          <Grid item xs={12} md={6}>
            <Card>
              <MDBox
                mx={2}
                mt={-3}
                py={3}
                px={2}
                variant="gradient"
                bgColor="success"
                borderRadius="lg"
                coloredShadow="success"
              >
                <MDTypography variant="h6" color="white" fontWeight="medium">
                  About SaafPakistan
                </MDTypography>
              </MDBox>
              <MDBox p={3}>
                <MDTypography variant="body2" color="text" paragraph>
                  SaafPakistan is a comprehensive recycling management system that connects
                  users with riders for waste collection. Request pickup for your recyclable
                  materials and contribute to a cleaner environment.
                </MDTypography>
                <MDTypography variant="body2" color="text">
                  <strong>How it works:</strong>
                </MDTypography>
                <MDTypography variant="body2" color="text" sx={{ mt: 1 }}>
                  1. Create a pickup request with your address and waste details
                </MDTypography>
                <MDTypography variant="body2" color="text">
                  2. A rider will be assigned to collect your recyclables
                </MDTypography>
                <MDTypography variant="body2" color="text">
                  3. Track your request status until completion
                </MDTypography>
              </MDBox>
            </Card>
          </Grid>
        </Grid>
      </MDBox>
    </UserDashboardLayout>
  );
}

export default UserDashboard;