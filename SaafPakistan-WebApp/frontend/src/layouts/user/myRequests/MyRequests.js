import DashboardLayout from "examples/LayoutContainers/DashboardLayout";
import DashboardNavbar from "examples/Navbars/DashboardNavbar";
import MDBox from "components/MDBox";
import MDTypography from "components/MDTypography";
import Grid from "@mui/material/Grid";
import Card from "@mui/material/Card";
import MDButton from "components/MDButton";
import { useContext, useEffect, useState } from "react";
import { AuthContext } from "context/AuthContext";
import { getAuth } from "firebase/auth";
import * as apiService from "../../api-service";
import { useNavigate } from "react-router-dom";
import MDSnackbar from "components/MDSnackbar";
import Table from "@mui/material/Table";
import TableBody from "@mui/material/TableBody";
import TableCell from "@mui/material/TableCell";
import TableContainer from "@mui/material/TableContainer";
import TableHead from "@mui/material/TableHead";
import TableRow from "@mui/material/TableRow";
import Paper from "@mui/material/Paper";
import Chip from "@mui/material/Chip";
import IconButton from "@mui/material/IconButton";
import VisibilityIcon from "@mui/icons-material/Visibility";
import CancelIcon from "@mui/icons-material/Cancel";
import CircularProgress from "@mui/material/CircularProgress";
import Dialog from "@mui/material/Dialog";
import DialogTitle from "@mui/material/DialogTitle";
import DialogContent from "@mui/material/DialogContent";
import DialogActions from "@mui/material/DialogActions";
import CloseIcon from "@mui/icons-material/Close";

function MyRequests() {
  const { currentUser } = useContext(AuthContext);
  const [requests, setRequests] = useState([]);
  const [loading, setLoading] = useState(true);
  const [snackbar, setSnackbar] = useState({ open: false, message: "", color: "success" });
  const [selectedRequest, setSelectedRequest] = useState(null);
  const [detailModalOpen, setDetailModalOpen] = useState(false);
  const [cancelModalOpen, setCancelModalOpen] = useState(false);
  const [cancelling, setCancelling] = useState(false);
  const navigate = useNavigate();
  const auth = getAuth();

  const fetchRequests = async () => {
    try {
      if (auth.currentUser) {
        const idToken = await auth.currentUser.getIdToken();
        const data = await apiService.getUserRequests({ userIdToken: idToken });
        setRequests(data);
      }
    } catch (error) {
      console.error("Error fetching requests:", error);
      setSnackbar({
        open: true,
        message: "Failed to load requests",
        color: "error",
      });
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchRequests();
  }, [auth]);

  const getStatusColor = (status) => {
    switch (status) {
      case "Pending":
        return "warning";
      case "Assigned":
        return "info";
      case "Completed":
        return "success";
      case "Cancelled":
        return "error";
      default:
        return "default";
    }
  };

  const handleViewDetails = (request) => {
    setSelectedRequest(request);
    setDetailModalOpen(true);
  };

  const handleCancelClick = (request) => {
    setSelectedRequest(request);
    setCancelModalOpen(true);
  };

  const handleCancelRequest = async () => {
    if (!selectedRequest) return;

    setCancelling(true);
    try {
      const idToken = await auth.currentUser.getIdToken();
      await apiService.cancelUserRequest({
        userIdToken: idToken,
        id: selectedRequest.id,
      });

      setSnackbar({
        open: true,
        message: "Request cancelled successfully",
        color: "success",
      });

      setCancelModalOpen(false);
      fetchRequests();
    } catch (error) {
      console.error("Error cancelling request:", error);
      setSnackbar({
        open: true,
        message: error.response?.data?.error || "Failed to cancel request",
        color: "error",
      });
    } finally {
      setCancelling(false);
    }
  };

  const closeSnackbar = () => {
    setSnackbar({ ...snackbar, open: false });
  };

  const formatDate = (dateString) => {
    if (!dateString) return "N/A";
    const date = new Date(dateString);
    return date.toLocaleDateString("en-US", {
      year: "numeric",
      month: "short",
      day: "numeric",
    });
  };

  return (
    <DashboardLayout>
      <DashboardNavbar />
      <MDBox py={3}>
        <MDBox mb={4} display="flex" justifyContent="space-between" alignItems="center">
          <MDBox>
            <MDTypography variant="h4" fontWeight="bold" gutterBottom>
              My Requests
            </MDTypography>
            <MDTypography variant="body1" color="text">
              View and manage all your pickup requests.
            </MDTypography>
          </MDBox>
          <MDButton
            variant="gradient"
            color="info"
            onClick={() => navigate("/user/create-request")}
          >
            New Request
          </MDButton>
        </MDBox>

        <Grid container spacing={3}>
          <Grid item xs={12}>
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
                  All Pickup Requests
                </MDTypography>
              </MDBox>
              <MDBox p={3}>
                {loading ? (
                  <MDBox display="flex" justifyContent="center" p={4}>
                    <CircularProgress />
                  </MDBox>
                ) : requests.length === 0 ? (
                  <MDBox textAlign="center" p={4}>
                    <MDTypography variant="h6" color="text" gutterBottom>
                      No requests yet
                    </MDTypography>
                    <MDTypography variant="body2" color="text" paragraph>
                      Create your first pickup request to get started.
                    </MDTypography>
                    <MDButton
                      variant="gradient"
                      color="info"
                      onClick={() => navigate("/user/create-request")}
                      sx={{ mt: 2 }}
                    >
                      Create Request
                    </MDButton>
                  </MDBox>
                ) : (
                  <TableContainer component={Paper} variant="outlined">
                    <Table>
                      <TableHead>
                        <TableRow>
                          <TableCell><strong>ID</strong></TableCell>
                          <TableCell><strong>Date</strong></TableCell>
                          <TableCell><strong>Time</strong></TableCell>
                          <TableCell><strong>Address</strong></TableCell>
                          <TableCell><strong>Waste Type</strong></TableCell>
                          <TableCell><strong>Status</strong></TableCell>
                          <TableCell><strong>Actions</strong></TableCell>
                        </TableRow>
                      </TableHead>
                      <TableBody>
                        {requests.map((request) => (
                          <TableRow key={request.id}>
                            <TableCell>
                              <MDTypography variant="body2">
                                {request.id.substring(0, 8)}...
                              </MDTypography>
                            </TableCell>
                            <TableCell>{formatDate(request.date)}</TableCell>
                            <TableCell>{request.time}</TableCell>
                            <TableCell>
                              <MDTypography variant="body2" sx={{ maxWidth: 200 }}>
                                {request.address}
                              </MDTypography>
                            </TableCell>
                            <TableCell>{request.wasteType}</TableCell>
                            <TableCell>
                              <Chip
                                label={request.status}
                                color={getStatusColor(request.status)}
                                size="small"
                              />
                            </TableCell>
                            <TableCell>
                              <IconButton
                                color="info"
                                onClick={() => handleViewDetails(request)}
                                size="small"
                              >
                                <VisibilityIcon />
                              </IconButton>
                              {request.status === "Pending" && (
                                <IconButton
                                  color="error"
                                  onClick={() => handleCancelClick(request)}
                                  size="small"
                                >
                                  <CancelIcon />
                                </IconButton>
                              )}
                            </TableCell>
                          </TableRow>
                        ))}
                      </TableBody>
                    </Table>
                  </TableContainer>
                )}
              </MDBox>
            </Card>
          </Grid>
        </Grid>
      </MDBox>

      {/* Detail Modal */}
      <Dialog
        open={detailModalOpen}
        onClose={() => setDetailModalOpen(false)}
        maxWidth="sm"
        fullWidth
      >
        <DialogTitle>
          Request Details
          <IconButton
            onClick={() => setDetailModalOpen(false)}
            sx={{ position: "absolute", right: 8, top: 8 }}
          >
            <CloseIcon />
          </IconButton>
        </DialogTitle>
        <DialogContent dividers>
          {selectedRequest && (
            <Grid container spacing={2}>
              <Grid item xs={12}>
                <MDTypography variant="subtitle2" color="text">
                  Request ID
                </MDTypography>
                <MDTypography variant="body1">{selectedRequest.id}</MDTypography>
              </Grid>
              <Grid item xs={6}>
                <MDTypography variant="subtitle2" color="text">
                  Date
                </MDTypography>
                <MDTypography variant="body1">{formatDate(selectedRequest.date)}</MDTypography>
              </Grid>
              <Grid item xs={6}>
                <MDTypography variant="subtitle2" color="text">
                  Time
                </MDTypography>
                <MDTypography variant="body1">{selectedRequest.time}</MDTypography>
              </Grid>
              <Grid item xs={12}>
                <MDTypography variant="subtitle2" color="text">
                  Address
                </MDTypography>
                <MDTypography variant="body1">{selectedRequest.address}</MDTypography>
              </Grid>
              <Grid item xs={6}>
                <MDTypography variant="subtitle2" color="text">
                  Waste Type
                </MDTypography>
                <MDTypography variant="body1">{selectedRequest.wasteType}</MDTypography>
              </Grid>
              <Grid item xs={6}>
                <MDTypography variant="subtitle2" color="text">
                  Status
                </MDTypography>
                <Chip
                  label={selectedRequest.status}
                  color={getStatusColor(selectedRequest.status)}
                  size="small"
                />
              </Grid>
              <Grid item xs={12}>
                <MDTypography variant="subtitle2" color="text">
                  Notes
                </MDTypography>
                <MDTypography variant="body1">
                  {selectedRequest.notes || "No notes provided"}
                </MDTypography>
              </Grid>
              {selectedRequest.riderName && (
                <>
                  <Grid item xs={6}>
                    <MDTypography variant="subtitle2" color="text">
                      Assigned Rider
                    </MDTypography>
                    <MDTypography variant="body1">{selectedRequest.riderName}</MDTypography>
                  </Grid>
                  <Grid item xs={6}>
                    <MDTypography variant="subtitle2" color="text">
                      Payment Status
                    </MDTypography>
                    <MDTypography variant="body1">{selectedRequest.paymentStatus}</MDTypography>
                  </Grid>
                </>
              )}
              <Grid item xs={12}>
                <MDTypography variant="subtitle2" color="text">
                  Created At
                </MDTypography>
                <MDTypography variant="body1">
                  {formatDate(selectedRequest.createdAt)}
                </MDTypography>
              </Grid>
            </Grid>
          )}
        </DialogContent>
        <DialogActions>
          <MDButton onClick={() => setDetailModalOpen(false)} color="info">
            Close
          </MDButton>
        </DialogActions>
      </Dialog>

      {/* Cancel Confirmation Modal */}
      <Dialog
        open={cancelModalOpen}
        onClose={() => setCancelModalOpen(false)}
        maxWidth="xs"
        fullWidth
      >
        <DialogTitle>Cancel Request</DialogTitle>
        <DialogContent>
          <MDTypography variant="body1">
            Are you sure you want to cancel this pickup request? This action cannot be undone.
          </MDTypography>
        </DialogContent>
        <DialogActions>
          <MDButton onClick={() => setCancelModalOpen(false)} color="info">
            No, Keep It
          </MDButton>
          <MDButton
            onClick={handleCancelRequest}
            color="error"
            disabled={cancelling}
          >
            {cancelling ? "Cancelling..." : "Yes, Cancel"}
          </MDButton>
        </DialogActions>
      </Dialog>

      <MDSnackbar
        open={snackbar.open}
        onClose={closeSnackbar}
        message={snackbar.message}
        color={snackbar.color}
        autoHideDuration={4000}
        location="top"
        close={closeSnackbar}
      />
    </DashboardLayout>
  );
}

export default MyRequests;